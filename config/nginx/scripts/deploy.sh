
#!/bin/bash

# JustClik AI v2 - Deployment Script
# Run this after server setup is complete

set -e

echo "🚀 Starting JustClik AI v2 Deployment..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env file exists
if [ ! -f .env ]; then
    print_error ".env file not found! Please copy .env.example to .env and configure it."
    exit 1
fi

# Load environment variables
source .env

print_status "Checking environment configuration..."
if [ -z "$DOMAIN" ] || [ -z "$COHERE_API_KEY" ] || [ -z "$DB_PASSWORD" ]; then
    print_error "Missing required environment variables. Please check your .env file."
    exit 1
fi

print_status "Setting up Nginx configuration..."
# Copy nginx config
cp config/nginx/justclik.conf /etc/nginx/sites-available/justclik
ln -sf /etc/nginx/sites-available/justclik /etc/nginx/sites-enabled/justclik

# Test nginx configuration
nginx -t

print_status "Restarting Nginx..."
systemctl restart nginx

print_status "Setting up SSL certificate..."
# Get SSL certificate from Let's Encrypt
certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

print_status "Pulling Docker images..."
docker compose pull

print_status "Starting database..."
docker compose up -d postgres

print_status "Waiting for database to be ready..."
sleep 30

print_status "Starting LibreChat..."
docker compose up -d librechat

print_status "Waiting for services to start..."
sleep 45

print_status "Checking service status..."
docker compose ps

print_status "Testing application..."
# Test if the application is responding
if curl -f -s https://$DOMAIN/health > /dev/null; then
    print_status "✅ Application is responding!"
else
    print_warning "⚠️  Application may still be starting. Check logs with: docker compose logs"
fi

print_status "Setting up backup cron job..."
# Add daily backup to crontab
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/justclik-ai/scripts/backup.sh") | crontab -

print_status "Setting up monitoring..."
# Add health check to crontab (every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * /opt/justclik-ai/scripts/health-check.sh") | crontab -

print_status "✅ Deployment completed successfully!"
echo ""
print_status "🎉 JustClik AI v2 is now live at: https://$DOMAIN"
echo ""
print_warning "Next steps:"
echo "1. Visit https://$DOMAIN and create an admin account"
echo "2. Configure the Mortgage Assistant agent"
echo "3. Test file uploads and web search"
echo "4. Add custom branding assets"
echo ""
print_status "Useful commands:"
echo "- View logs: docker compose logs -f"
echo "- Restart: docker compose restart"
echo "- Stop: docker compose down"
echo "- Backup: ./scripts/backup.sh"
echo ""
print_status "🚀 Happy mortgage brokering!"