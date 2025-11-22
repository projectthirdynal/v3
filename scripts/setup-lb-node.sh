#!/bin/bash
set -e

# Load Balancer Node Setup Script (Nginx)
# Run as root

echo "Installing Nginx..."
apt-get update
apt-get install -y nginx

echo "Configuring Nginx..."
# Embed nginx lb config
cat <<EOF > /etc/nginx/sites-available/myshop-lb
upstream myshop_backend {
    server 192.168.120.71:80;
    server 192.168.120.72:80;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://myshop_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/myshop-lb /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

echo "Load Balancer Setup Complete!"
