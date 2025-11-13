
# CHECKLIST.md
Quick checklist to verify the deployment

- [ ] EC2 instance running (Apache active)
- [ ] PHP installed and phpinfo page loads
- [ ] WordPress files present in /var/www/html
- [ ] wp-config.php configured with RDS endpoint and creds
- [ ] RDS instance available and wpuser can connect
- [ ] AMI created from working EC2
- [ ] At least two EC2 instances launched from AMI
- [ ] Target group created and instances registered
- [ ] ALB created, Active, and routing to targets (healthy)
- [ ] Domain (Route53) and SSL (ACM) configured (optional)
