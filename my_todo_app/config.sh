#!/bin/bash

# Script to set up database and table on AWS RDS MySQL instance
# Run with sudo if needed for file permissions (e.g., sudo ./setup_db.sh)

# Exit on error
set -x
# Variables
DB_HOST="database-1.cj2seuige0e8.eu-west-2.rds.amazonaws.com"
DB_USER="admin"
DB_PASS="Sonship123$"
DB_NAME="todo-app"
TABLE_NAME="tasks"


S3_PATH="todo-app/"                   # Path to your files in the bucket
LOCAL_DIR="/var/www/todo-app/"        # Recommended location for web apps
AWS_REGION="eu-west-2"                # London region (change if different)
BUCKET_NAME="todo-list-1987"
S3_CONFIG_PATH="todo-app/nginx.conf"
NGINX_CONF="/etc/nginx/nginx.conf"
BACKUP_DIR="/etc/nginx/backups"




echo "########################################"
echo "Installing PHP and common modules (Amazon Linux 2023)"
echo "########################################"

# Update repos and install PHP
yum install -y php php-cli php-fpm php-mysqlnd php-xml php-mbstring php-curl php-json php-common php-opcache > /dev/null

echo "PHP installation completed."



echo "########################################"
echo " Starting S3 File Copy Operation"
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
mkdir -p "$LOCAL_DIR"
chown -R $USER:$USER "$LOCAL_DIR"

# Copy files from S3 with detailed output
echo "Copying files from S3..."
aws s3 sync "s3://$BUCKET_NAME/$S3_PATH" "$LOCAL_DIR" \
    --region "$AWS_REGION" \
    --exclude ".git/*" \
    --delete



echo "########################################"
echo " File Copy Completed Successfully"
echo "########################################"













echo "########################################"
echo " NGINX Configuration Replacement Script"
echo "########################################"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: This script must be run as root"
  exit 1
fi

# Install AWS CLI if not installed
if ! command -v aws &> /dev/null; then
  echo "Installing AWS CLI..."
  yum install -y awscli > /dev/null
  echo "AWS CLI installed."
fi

# Install Nginx if not installed
if ! command -v nginx &> /dev/null; then
  echo "Installing Nginx..."
  yum amazon-linux-extras install nginx1 -y > /dev/null
  systemctl enable nginx
  systemctl start nginx
  echo "Nginx installed and started."
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup existing config
BACKUP_FILE="$BACKUP_DIR/nginx.conf.$(date +%Y%m%d-%H%M%S)"
echo "Backing up current config to $BACKUP_FILE..."
cp "$NGINX_CONF" "$BACKUP_FILE"

# Download new config from S3
echo "Downloading new configuration from S3..."
if aws s3 cp "s3://$BUCKET_NAME/$S3_CONFIG_PATH" "$NGINX_CONF" --region "$AWS_REGION"; then
  echo "Successfully downloaded new configuration."

  # Validate config before applying
  echo "Testing new configuration..."
  if nginx -t; then
    echo "Configuration test successful. Restarting Nginx..."
    systemctl restart nginx
    echo "Nginx restarted with new configuration."
  else
    echo "ERROR: New configuration test failed. Restoring backup..."
    cp "$BACKUP_FILE" "$NGINX_CONF"
    systemctl restart nginx
    exit 1
  fi
else
  echo "ERROR: Failed to download configuration from S3. Using original config."
  exit 1
fi

echo "########################################"
echo " NGINX Configuration Update Complete"
echo "########################################"
