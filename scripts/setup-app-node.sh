#!/bin/bash
set -e

# App Node Setup Script (PHP + Nginx + Worker)
# Run as root

APP_DIR="/var/www/myshop"

echo "Installing prerequisites..."
apt-get update
apt-get install -y software-properties-common curl git unzip supervisor

echo "Adding PHP PPA..."
add-apt-repository ppa:ondrej/php -y
apt-get update

echo "Installing PHP 8.2 and Nginx..."
apt-get install -y nginx php8.2-fpm php8.2-cli php8.2-common php8.2-mysql php8.2-zip php8.2-gd \
    php8.2-mbstring php8.2-curl php8.2-xml php8.2-bcmath php8.2-intl php8.2-redis

echo "Installing Composer..."
if [ ! -f /usr/local/bin/composer ]; then
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
fi

echo "Setting up App Directory..."
mkdir -p $APP_DIR/storage/logs
chown -R www-data:www-data $APP_DIR

echo "Configuring Nginx..."
# Embed nginx config
cat <<EOF > /etc/nginx/sites-available/myshop
server {
    listen 80;
    server_name _;
    root /var/www/myshop/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/myshop /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

echo "Configuring Supervisor..."
# Embed supervisor config
cat <<EOF > /etc/supervisor/conf.d/myshop-worker.conf
[program:myshop-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/myshop/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/myshop/storage/logs/worker.log
stopwaitsecs=3600
EOF

supervisorctl reread
supervisorctl update
# Don't start yet as code might not be there
# supervisorctl start myshop-worker:*

echo "App Node Setup Complete!"
echo "Next steps:"
echo "1. Clone your code into $APP_DIR"
echo "2. Run 'composer install --no-dev' in $APP_DIR"
echo "3. Set up .env file"
echo "4. Run 'php artisan migrate'"
echo "5. Run 'supervisorctl start myshop-worker:*'"
