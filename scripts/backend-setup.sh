#!/bin/bash
apt-get update
apt-get install -y software-properties-common
              
# Add PHP repository              
add-apt-repository -y ppa:ondrej/php
apt-get update
              
# Install PHP 8.2 and extensions
apt-get install -y php8.2 php8.2-cli php8.2-fpm php8.2-mysql php8.2-xml php8.2-curl \
        php8.2-mbstring php8.2-zip php8.2-gd php8.2-bcmath php8.2-intl
              
# Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
              
# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
              
# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
              
# Add ubuntu user to docker group
usermod -aG docker ubuntu
              
# Enable services
systemctl enable docker
systemctl start docker
systemctl enable php8.2-fpm
systemctl start php8.2-fpm
              
# Install Git
apt-get install -y git
              
# Install monitoring tools
apt-get install -y htop iotop nethogs
              
echo "Backend server setup completed" > /var/log/user-data.log