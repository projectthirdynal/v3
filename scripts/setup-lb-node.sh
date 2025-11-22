#!/bin/bash

# Load Balancer Node Setup Script (Nginx)
# Run as root

apt-get update
apt-get install -y nginx

# Configure Nginx
cp ../conf/nginx-lb.conf /etc/nginx/sites-available/myshop-lb
ln -sf /etc/nginx/sites-available/myshop-lb /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

echo "Load Balancer Setup Complete!"
