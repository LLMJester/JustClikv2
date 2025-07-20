#!/bin/bash

# JustClik AI v2 - Server Setup Script
# Run this on a fresh Ubuntu 22.04 server

set -e  # Exit on any error

echo "🚀 Starting JustClik AI v2 Server Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root (use sudo)"
    exit 1
fi

print_status "Updating system packages..."
apt update && apt upgrade -y

print_status "Installing required packages..."
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git \
    nginx \
    certbot \
    python3-certbot-nginx \
    ufw \
    htop \
    unzip

print_status "Installing Docker..."
# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

print_status "Configuring Docker..."
systemctl enable docker
systemctl start docker

# Add current user to docker group if not root
if [ "$SUDO_USER" ]; then
    usermod -aG docker $SUDO_USER
    print_status "Added $SUDO_USER to docker group"
fi

print_status "Setting up firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable

print_status "Creating project directory..."
mkdir -p /opt/justclik-ai
cd /opt/justclik-ai

print_status "Setting up directory structure..."
mkdir -p {data,logs,backups,branding,config/nginx,scripts,monitoring}

print_status "Setting permissions..."
chmod +x /opt/justclik-ai/scripts/*.sh 2>/dev/null || true

print_status "Configuring Nginx..."
# Remove default site
rm -f /etc/nginx/sites-enabled/default

print_status "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create symlink for easier access
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

print_status "Verifying installations..."
docker --version
docker-compose --version
nginx -v

print_status "✅ Server setup completed successfully!"
print_warning "Next steps:"
echo "1. Copy your project files to /opt/justclik-ai"
echo "2. Configure your .env file"
echo "3. Set up DNS for your domain"
echo "4. Run the deployment script"

print_status "🎉 Ready for JustClik AI v2 deployment!"