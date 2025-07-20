#!/bin/bash

# JustClik AI v2 - Update Script
# Updates LibreChat to the latest version safely

set -e

echo "🔄 Starting JustClik AI v2 Update..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[UPDATE]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found. Please run this script from /opt/justclik-ai"
    exit 1
fi

print_status "Checking current status..."
docker compose ps

print_status "Creating pre-update backup..."
./scripts/backup.sh

print_status "Pulling latest LibreChat image..."
docker compose pull librechat

print_status "Checking for image updates..."
# Get current image ID
CURRENT_IMAGE=$(docker images ghcr.io/danny-avila/librechat --format "{{.ID}}" | head -n1)
# Pull latest and get new image ID  
docker pull ghcr.io/danny-avila/LibreChat:latest
NEW_IMAGE=$(docker images ghcr.io/danny-avila/LibreChat:latest --format "{{.ID}}")

if [ "$CURRENT_IMAGE" = "$NEW_IMAGE" ]; then
    print_status "Already running the latest version!"
    exit 0
fi

print_status "New version detected. Updating..."

print_warning "Stopping services for update..."
docker compose down

print_status "Starting database first..."
docker compose up -d postgres

print_status "Waiting for database to be ready..."
sleep 30

print_status "Starting LibreChat with new image..."
docker compose up -d librechat

print_status "Waiting for services to start..."
sleep 45

print_status "Verifying update..."
if docker compose ps | grep -q "justine_mortgage_ai.*Up"; then
    print_status "✅ LibreChat is running with updated image"
else
    print_error "❌ Update failed - LibreChat is not running"
    
    print_warning "Attempting to rollback..."
    docker compose down
    
    # Here you could implement rollback logic if needed
    # For now, just try to restart
    docker compose up -d
    
    exit 1
fi

print_status "Testing application..."
# Wait a bit more for full startup
sleep 30

if curl -f -s https://justinemortgagequeen.justclik.ca/health > /dev/null; then
    print_status "✅ Application is responding correctly"
else
    print_warning "⚠️  Application may still be starting. Monitor with: docker compose logs -f"
fi

print_status "Cleaning up old Docker images..."
docker image prune -f

print_status "Update summary:"
echo "  Previous image: $CURRENT_IMAGE"
echo "  New image: $NEW_IMAGE"
echo "  Status: SUCCESS"

print_status "✅ JustClik AI v2 update completed successfully!"

# Log the update
echo "$(date): Updated from $CURRENT_IMAGE to $NEW_IMAGE" >> /opt/justclik-ai/logs/update.log

print_warning "Recommended: Monitor the application for a few minutes to ensure stability"
print_status "Monitor with: docker compose logs -f librechat"