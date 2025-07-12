#!/bin/bash

# Script to set up database and table on AWS RDS MySQL instance
# Run with sudo if needed for file permissions (e.g., sudo ./setup_db.sh)

# Exit on error
set -e
set -x

# Variables
DB_HOST="${db_host}"
DB_USER="${db_user}"
DB_PASS="${db_pass}"
DB_NAME="${db_name}"
TABLE_NAME="tasks"


S3_PATH="todo-app/"                   # Path to your files in the bucket
LOCAL_DIR="/home/ec2-user/todo-app/"        # Recommended location for web apps
AWS_REGION="eu-west-2"                # London region (change if different)
BUCKET_NAME="todo-list-1987"
S3_CONFIG_PATH="todo-app/nginx.conf"
NGINX_CONF="/etc/nginx/nginx.conf"
BACKUP_DIR="/etc/nginx/backups"



echo "########################################"
echo "Installing MYSQL and create table "
echo "########################################"

sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
wget http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
sudo yum localinstall -y mysql57-community-release-el7-8.noarch.rpm
sudo yum install -y mysql-community-server

sudo systemctl start mysqld 
sudo systemctl enable mysqld 


mysql -h "$DB_HOST" -P 3306 -u "$DB_USER" -p"$DB_PASS"<<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
USE \`$DB_NAME\`;
CREATE TABLE IF NOT EXISTS \`$TABLE_NAME\` (
  \`id\` int(11) NOT NULL AUTO_INCREMENT,
  \`title\` varchar(255) NOT NULL,
  \`is_done\` tinyint(1) DEFAULT 0,
  \`created_at\` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

EOF
echo "#################################################"
echo "Installing PHP and common modules (Amazon Linux 2023)"
echo "#################################################"

# Update repos and install PHP
amazon-linux-extras enable php8.1
yum clean metadata
yum install -y php php-cli php-fpm php-mysqlnd php-xml php-mbstring php-curl php-json php-common php-opcache

echo "PHP installation completed."





echo "########################################"
echo " Starting S3 Source code Copy Operation"
echo " Source: s3://$BUCKET_NAME/$S3_PATH"
echo " Destination: $LOCAL_DIR"
echo "########################################"

# Install AWS CLI (if not installed)
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    yum install -y awscli > /dev/null
    echo "AWS CLI installed."
fi

# Create local directory with proper permissions
echo "Creating local directory..."
sudo chmod 755 /home/ec2-user
mkdir -p "$LOCAL_DIR"
chown -R $USER:$USER "$LOCAL_DIR"

# Copy files from S3 with detailed output
echo "Copying files from S3..."
aws s3 sync "s3://$BUCKET_NAME/$S3_PATH" "$LOCAL_DIR" \
    --region "$AWS_REGION" \
    --exclude ".git/*" \
    --delete



echo "########################################"
echo " Source code Copy Completed Successfully"
echo "########################################"






echo "########################################"
echo " NGINX Configuration Replacement Script"
echo "########################################"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: This script must be run as root"
  exit 1
fi

# Install Nginx if not installed
if ! command -v nginx &> /dev/null; then
  echo "Installing Nginx..."

  # Enable nginx1 extras repo for Amazon Linux 2
  amazon-linux-extras enable nginx1
  yum clean metadata
  yum install -y nginx

  systemctl enable nginx
  systemctl start nginx

  echo "Nginx installed and started."
fi

# Download new nginx.conf from S3 (replace existing without backup)
echo "Downloading new configuration from S3..."
if aws s3 cp "s3://$BUCKET_NAME/$S3_CONFIG_PATH" "$NGINX_CONF" --region "$AWS_REGION"; then
  echo "Successfully downloaded new configuration."

  # Test the new Nginx configuration
  echo "Testing new configuration..."
  if nginx -t; then
    echo "Configuration test successful. Restarting Nginx..."
    systemctl restart nginx
    sudo systemctl start php-fpm
    sudo systemctl enable php-fpm
    echo "Nginx restarted with new configuration."
  else
    echo "ERROR: New configuration test failed. Not restarting Nginx."
    exit 1
  fi
else
  echo "ERROR: Failed to download configuration from S3."
  exit 1
fi




