#!/bin/bash
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              
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
              
# Enable Docker service
systemctl enable docker
systemctl start docker
              
# Install monitoring tools
apt-get install -y htop iotop nethogs
              
echo "Frontend server setup completed" > /var/log/user-data.log