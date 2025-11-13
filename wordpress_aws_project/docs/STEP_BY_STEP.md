
# STEP_BY_STEP.md
Chronological step-by-step approach used to deploy WordPress on AWS (EC2 + RDS + ALB)

> Use this as the master how-to and reference for reproducing the project.

---

## 1. EC2 - Prepare the web server
1. Launch EC2 instance (Amazon Linux 2023).
2. SSH into the instance:
   ```
   ssh -i "key.pem" ec2-user@<EC2_PUBLIC_IP>
   ```
3. Update and install required packages:
   ```bash
   sudo dnf update -y
   sudo dnf install -y httpd mariadb105 php php-mysqlnd php-fpm php-json php-common php-xml php-gd php-curl php-mbstring php-intl php-cli php-zip wget tar
   ```
4. Start and enable Apache:
   ```bash
   sudo systemctl enable --now httpd
   ```
5. Verify Apache:
   - Open http://<EC2_PUBLIC_IP> -> "It works!"

---

## 2. Download & prepare WordPress files
1. Download and extract:
   ```bash
   wget https://wordpress.org/latest.tar.gz
   tar -xzf latest.tar.gz
   ```
2. Copy files to Apache root:
   ```bash
   sudo cp -r ~/wordpress/* /var/www/html/
   ```
3. Remove Apache default page:
   ```bash
   sudo rm -f /var/www/html/index.html
   ```
4. Set permissions:
   ```bash
   sudo chown -R apache:apache /var/www/html
   sudo find /var/www/html -type d -exec chmod 755 {} \;
   sudo find /var/www/html -type f -exec chmod 644 {} \;
   ```

---

## 3. RDS - Create MySQL database
1. In AWS Console → RDS → Create database (MySQL, free tier)
   - DB identifier: mysqlwordpress
   - Master username: admin
   - Master password: root12345
   - VPC: choose the same as EC2
   - Public access: No (recommended if EC2 in same VPC)
2. Wait until status = Available.
3. From EC2, test connectivity:
   ```bash
   mysql -h <RDS_ENDPOINT> -P 3306 -u admin -p
   ```
4. Inside MySQL (admin):
   ```sql
   CREATE DATABASE wordpress;
   CREATE USER 'wpuser'@'%' IDENTIFIED BY 'root12345';
   GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
   FLUSH PRIVILEGES;
   ```

---

## 4. Configure WordPress to use RDS
1. Edit wp-config.php:
   ```bash
   sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
   sudo nano /var/www/html/wp-config.php
   ```
2. Update DB section:
   ```php
   define( 'DB_NAME', 'wordpress' );
   define( 'DB_USER', 'wpuser' );
   define( 'DB_PASSWORD', 'root12345' );
   define( 'DB_HOST', '<RDS_ENDPOINT>' );
   ```
3. Add unique salts (generate from https://api.wordpress.org/secret-key/1.1/salt/).
4. Restart Apache:
   ```bash
   sudo systemctl restart httpd
   ```

---

## 5. Verify site & database connection
1. Test DB user:
   ```bash
   mysql -h <RDS_ENDPOINT> -P 3306 -u wpuser -p
   ```
2. Visit http://<EC2_PUBLIC_IP>/ and complete WordPress install.

---

## 6. Create AMI from the working EC2
1. EC2 Console → Select instance → Actions → Image and templates → Create image
2. Name: wordpress-ami
3. Wait until AMI becomes Available.

---

## 7. Launch instances from AMI (for scaling)
1. EC2 → AMIs → Select wordpress-ami → Launch instance from image
2. Launch at least 2 instances in different AZs for ALB

---

## 8. Target Group & ALB
1. EC2 → Target Groups → Create target group:
   - Target type: Instances
   - Protocol: HTTP, Port: 80
   - VPC: same VPC
   - Health check path: /
2. Register EC2 instances (wordpress nodes) into the target group.
3. EC2 → Load Balancers → Create Application Load Balancer (internet-facing):
   - Add at least two subnets (different AZs)
   - Security group allowing HTTP (80) inbound
   - Listener: HTTP :80, forward to target group
4. Wait until ALB state = Active and targets show healthy.

---

## 9. DNS & SSL (optional)
1. Request ACM certificate for your domain.
2. Add HTTPS listener to ALB and attach the certificate.
3. Use Route53 to point your domain to the ALB (alias A record).

---

## Troubleshooting quick list
- `Unknown MySQL server host` → RDS endpoint incorrect, or DNS/VPC issue.
- `Can't connect to MySQL server` → Security group inbound for 3306 not set correctly.
- `Access denied` → Wrong DB credentials/host when creating MySQL user.
- ALB target unhealthy → EC2 security group must allow traffic from ALB SG to port 80.

---
