#!/bin/bash
# helpers.sh - helpful commands used in the project

echo "Start Apache"
sudo systemctl enable --now httpd

echo "Restart PHP-FPM if exists"
sudo systemctl restart php-fpm || true

echo "Set ownership to apache"
sudo chown -R apache:apache /var/www/html

echo "Test DB connection"
echo "mysql -h <RDS_ENDPOINT> -P 3306 -u wpuser -p"

echo "Check ALB target group status (use AWS CLI):"
echo "aws elbv2 describe-target-health --target-group-arn <target-group-arn>"
