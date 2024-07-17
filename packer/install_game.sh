#!/bin/bash

# Update packages and install necessary software
sudo apt-get update -y
sudo apt-get install -y nginx git curl

# Remove the existing content in /var/www/html
sudo rm -rf /var/www/html/*

# Clone the game repository
sudo git clone https://github.com/se-interns-24/labyrinth_test.github.io.git /var/www/html

# Set the correct permissions
sudo chown -R www-data:www-data /var/www/html

# Install Node.js and npm
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Navigate to the game directory
cd /var/www/html

# Install npm dependencies
sudo npm install

# Create a systemd service file for the game
sudo tee /etc/systemd/system/game.service > /dev/null <<EOT
[Unit]
Description=Node.js Game Server
After=network.target

[Service]
ExecStart=/usr/bin/node /var/www/html/index.js
Restart=always
User=www-data
Group=www-data
Environment=PATH=/usr/bin:/usr/local/bin
Environment=NODE_ENV=production
WorkingDirectory=/var/www/html

[Install]
WantedBy=multi-user.target
EOT

# Reload systemd to recognize the new service and enable it
sudo systemctl daemon-reload
sudo systemctl enable game.service

# Start the game service
sudo systemctl start game.service

# Ensure Nginx is enabled and started
sudo systemctl enable nginx
sudo systemctl start nginx

# Configure Nginx to reverse proxy to your Node.js application
sudo tee /etc/nginx/sites-available/default > /dev/null <<EOT
server {
    listen 80;

    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOT

# Restart Nginx to apply the new configuration
sudo systemctl restart nginx