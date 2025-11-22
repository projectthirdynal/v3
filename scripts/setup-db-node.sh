#!/bin/bash
set -e

# Database Node Setup Script (MySQL)
# Run as root

DB_NAME="myshop"
DB_USER="myshop"
DB_PASS="secure_db_password"

echo "Installing MySQL..."
apt-get update
apt-get install -y mysql-server

echo "Configuring MySQL..."
# Use a separate config file for external access
echo "[mysqld]
bind-address = 0.0.0.0" > /etc/mysql/mysql.conf.d/99-external.cnf

echo "Restarting MySQL..."
systemctl restart mysql

# Wait for MySQL to be fully up
echo "Waiting for MySQL to initialize..."
sleep 5

echo "Creating Database and User..."
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
mysql -e "FLUSH PRIVILEGES;"

echo "Database Node Setup Complete!"
