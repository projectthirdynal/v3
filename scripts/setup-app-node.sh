#!/bin/bash

# App Node Setup Script (PHP + Nginx + Worker)
# Run as root

REPO_URL="https://github.com/aimeos/aimeos-laravel.git" # Replace with actual repo
APP_DIR="/var/www/myshop"

# Update and install dependencies
apt-get update
apt-get install -y nginx git unzip curl supervisor \
    php8.2-fpm php8.2-cli php8.2-common php8.2-mysql php8.2-zip php8.2-gd \
    php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath php8.2-intl php8.2-redis

# Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Setup App Directory
mkdir -p $APP_DIR
# In a real scenario, you'd clone here. For now, we assume files are copied or cloned.
# git clone $REPO_URL $APP_DIR
# For this script, we assume the user will copy the files manually or clone.

# Configure Nginx
cp ../conf/nginx-app.conf /etc/nginx/sites-available/myshop
ln -sf /etc/nginx/sites-available/myshop /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

# Configure Supervisor
cp ../conf/worker-supervisor.conf /etc/supervisor/conf.d/myshop-worker.conf
supervisorctl reread
supervisorctl update
supervisorctl start myshop-worker:*

echo "App Node Setup Complete! Don't forget to configure .env and set permissions."
