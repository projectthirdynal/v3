# Deployment Guide for Aimeos on Proxmox (5-Node Cluster)

This guide outlines the steps to deploy your Aimeos application on a **5-Node Cluster** (Bare Metal).

## Topology

| Node Role | IP Address | Description |
| :--- | :--- | :--- |
| **Load Balancer** | `192.168.120.70` | Nginx LB distributing traffic to App Servers. |
| **App Server 1** | `192.168.120.71` | PHP 8.2 + Nginx + Worker. |
| **App Server 2** | `192.168.120.72` | PHP 8.2 + Nginx + Worker. |
| **Database** | `192.168.120.73` | MySQL 8.0. |
| **Redis Cache** | `192.168.120.74` | Redis. |

## Prerequisites

*   **Root Access**: You need `sudo` or `root` access to all VMs.
*   **OS**: Ubuntu 22.04 LTS or 24.04 LTS.

## Step 1: Deploy Database Node (`192.168.120.73`)

1.  SSH into `192.168.120.73`.
2.  Copy `scripts/setup-db-node.sh` to the VM.
3.  Run the script:
    ```bash
    chmod +x setup-db-node.sh
    sudo ./setup-db-node.sh
    ```

## Step 2: Deploy Redis Node (`192.168.120.74`)

1.  SSH into `192.168.120.74`.
2.  Copy `scripts/setup-redis-node.sh` to the VM.
3.  Run the script:
    ```bash
    chmod +x setup-redis-node.sh
    sudo ./setup-redis-node.sh
    ```

## Step 3: Deploy App Servers (`.71` & `.72`)

**Repeat for BOTH App Servers.**

1.  SSH into the App Server.
2.  Copy `scripts/setup-app-node.sh` to the VM.
3.  Run the setup script:
    ```bash
    chmod +x setup-app-node.sh
    sudo ./setup-app-node.sh
    ```
4.  **Deploy Code**:
    *   Clone your repository to `/var/www/myshop`.
    *   Run `composer install --no-dev --optimize-autoloader`.
    *   Set permissions: `chown -R www-data:www-data /var/www/myshop`.
5.  **Configure Environment**:
    *   Copy `.env.example` to `.env`.
    *   Update `.env` with the new IPs:
        ```ini
        APP_ENV=production
        APP_DEBUG=false
        APP_URL=https://your-domain.com
        DB_HOST=192.168.120.73
        DB_PASSWORD=secure_db_password
        REDIS_HOST=192.168.120.74
        REDIS_PASSWORD=secure_redis_password
        ```
6.  **Run Migrations** (Only on ONE server):
    ```bash
    php artisan migrate --force
    ```
7.  **Start Worker**:
    ```bash
    sudo supervisorctl start myshop-worker:*
    ```

## Step 4: Deploy Load Balancer (`192.168.120.70`)

1.  SSH into `192.168.120.70`.
2.  Copy `scripts/setup-lb-node.sh` to the VM.
3.  Run the script:
    ```bash
    chmod +x setup-lb-node.sh
    sudo ./setup-lb-node.sh
    ```

## Maintenance

*   **Logs**:
    *   Nginx: `/var/log/nginx/error.log`
    *   Laravel: `/var/www/myshop/storage/logs/laravel.log`
    *   Worker: `/var/www/myshop/storage/logs/worker.log`
*   **Restart Worker**: `sudo supervisorctl restart myshop-worker:*`
