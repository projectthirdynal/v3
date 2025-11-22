# Deployment Guide for Aimeos on Proxmox (Bare Metal)

This guide outlines the steps to deploy your Aimeos application directly onto your Proxmox VMs (Ubuntu 22.04/24.04) without Docker.

## Topology

| Node Role | IP Address | Description |
| :--- | :--- | :--- |
| **Load Balancer** | `192.168.120.89` | Nginx LB distributing traffic to App Servers. |
| **App Server 1** | `192.168.120.198` | PHP 8.2 + Nginx + Worker. |
| **App Server 2** | `192.168.120.90` | PHP 8.2 + Nginx + Worker. |
| **Data Node** | `192.168.120.50` | MySQL 8.0 + Redis. |

## Prerequisites

*   **Root Access**: You need `sudo` or `root` access to all VMs.
*   **OS**: Ubuntu 22.04 LTS or 24.04 LTS.

## Step 1: Deploy Data Node (`192.168.120.50`)

1.  SSH into `192.168.120.50`.
2.  Copy `scripts/setup-data-node.sh` to the VM.
3.  Run the script:
    ```bash
    chmod +x setup-data-node.sh
    sudo ./setup-data-node.sh
    ```
    *Note: The script sets default passwords (`secure_db_password`, `secure_redis_password`). Change them in the script before running if needed.*

## Step 2: Deploy App Servers (`.198` & `.90`)

**Repeat for BOTH App Servers.**

1.  SSH into the App Server.
2.  Copy `scripts/setup-app-node.sh`, `conf/nginx-app.conf`, and `conf/worker-supervisor.conf` to the VM.
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
    *   Clone `.env.example` to `.env`.
    *   Update `.env`:
        ```ini
        APP_ENV=production
        APP_DEBUG=false
        APP_URL=https://your-domain.com
        DB_HOST=192.168.120.50
        DB_PASSWORD=secure_db_password
        REDIS_HOST=192.168.120.50
        REDIS_PASSWORD=secure_redis_password
        ```
6.  **Run Migrations** (Only on ONE server):
    ```bash
    php artisan migrate --force
    ```

## Step 3: Deploy Load Balancer (`192.168.120.89`)

1.  SSH into `192.168.120.89`.
2.  Copy `scripts/setup-lb-node.sh` and `conf/nginx-lb.conf` to the VM.
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
