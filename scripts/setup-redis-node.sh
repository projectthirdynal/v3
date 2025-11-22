#!/bin/bash
set -e

# Redis Node Setup Script
# Run as root

REDIS_PASS="secure_redis_password"

echo "Installing Redis..."
apt-get update
apt-get install -y redis-server

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

echo "Redis Node Setup Complete!"
