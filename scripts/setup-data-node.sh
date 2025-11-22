#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

# Data Node Setup Script (MySQL + Redis)
# Run as root

DB_NAME="myshop"
DB_USER="myshop"
DB_PASS="secure_db_password"
REDIS_PASS="secure_redis_password"

echo "Updating and installing dependencies..."
apt-get update
apt-get install -y mysql-server redis-server

echo "Configuring MySQL..."
# Use a separate config file for external access to avoid modifying the default config directly
# This is safer and less prone to sed errors
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

echo "Configuring Redis..."
# Backup redis config
if [ ! -f /etc/redis/redis.conf.bak ]; then
    cp /etc/redis/redis.conf /etc/redis/redis.conf.bak
fi

# Allow remote access to Redis
sed -i "s/^bind 127.0.0.1.*/bind 0.0.0.0/" /etc/redis/redis.conf
# Set password
sed -i "s/^# requirepass foobared/requirepass ${REDIS_PASS}/" /etc/redis/redis.conf

echo "Restarting Redis..."
systemctl restart redis-server

echo "Data Node Setup Complete!"
