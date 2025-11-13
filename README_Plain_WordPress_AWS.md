# WordPress Deployment on AWS — EC2 + RDS + ALB

This project demonstrates a complete, production-style deployment of WordPress on AWS using EC2, RDS MySQL, ALB, and AMI.

## 1. EC2 Setup
```
ssh -i "key.pem" ec2-user@<EC2_PUBLIC_IP>
sudo dnf update -y
sudo dnf install -y httpd mariadb105 php php-mysqlnd php-fpm php-json php-common php-xml php-gd php-curl php-mbstring php-intl php-cli php-zip wget tar
sudo systemctl enable --now httpd
```

## 2. WordPress Download & Configuration
```
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/
sudo rm -f /var/www/html/index.html
sudo chown -R apache:apache /var/www/html
```

## 3. RDS Setup
```
CREATE DATABASE wordpress;
CREATE USER 'wpuser'@'%' IDENTIFIED BY 'root12345';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
FLUSH PRIVILEGES;
```

## 4. wp-config.php
```
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', 'root12345');
define('DB_HOST', '<RDS_ENDPOINT>');
```

## 5. AMI Creation
- EC2 → Actions → Image → Create Image → wordpress-ami

## 6. Target Group
- Create TG → Instances → HTTP 80 → Health check `/`
- Register EC2 nodes launched from AMI.

## 7. ALB
- Create ALB → Internet-facing → 2 subnets  
- Listener: HTTP 80 → Forward to Target Group

Access via:
```
http://<ALB_DNS_NAME>
```

## Security Groups
- EC2: 22, 80 → 0.0.0.0/0  
- RDS: 3306 → EC2 SG  
- ALB: 80 → 0.0.0.0/0
