#!/bin/bash

# JustClik AI v2 - Backup Script
# Creates daily backups of database and user files

set -e

echo "🔄 Starting JustClik AI v2 Backup..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[BACKUP]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/justclik-ai/backups"
RETENTION_DAYS=7

# Ensure backup directory exists
mkdir -p $BACKUP_DIR

print_status "Creating backup for $DATE"

# Database backup
print_status "Backing up PostgreSQL database..."
if docker compose ps postgres | grep -q "Up"; then
    docker exec justine_mortgage_db pg_dump -U librechat librechat > $BACKUP_DIR/db_backup_$DATE.sql
    gzip $BACKUP_DIR/db_backup_$DATE.sql
    print_status "Database backup completed: db_backup_$DATE.sql.gz"
else
    print_error "PostgreSQL container is not running!"
    exit 1
fi

# Files backup
print_status "Backing up uploaded files..."
if [ -d "/opt/justclik-ai/data" ]; then
    tar -czf $BACKUP_DIR/files_backup_$DATE.tar.gz -C /opt/justclik-ai data/
    print_status "Files backup completed: files_backup_$DATE.tar.gz"
else
    print_warning "Data directory not found, skipping files backup"
fi

# Configuration backup
print_status "Backing up configuration files..."
tar -czf $BACKUP_DIR/config_backup_$DATE.tar.gz \
    --exclude='.env' \
    -C /opt/justclik-ai \
    config/ \
    docker-compose.yml \
    .env.example

print_status "Configuration backup completed: config_backup_$DATE.tar.gz"

# Calculate backup sizes
DB_SIZE=$(du -h $BACKUP_DIR/db_backup_$DATE.sql.gz 2>/dev/null | cut -f1 || echo "N/A")
FILES_SIZE=$(du -h $BACKUP_DIR/files_backup_$DATE.tar.gz 2>/dev/null | cut -f1 || echo "N/A")
CONFIG_SIZE=$(du -h $BACKUP_DIR/config_backup_$DATE.tar.gz 2>/dev/null | cut -f1 || echo "N/A")

print_status "Backup sizes:"
echo "  Database: $DB_SIZE"
echo "  Files: $FILES_SIZE"
echo "  Config: $CONFIG_SIZE"

# Cleanup old backups
print_status "Cleaning up backups older than $RETENTION_DAYS days..."
find $BACKUP_DIR -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

# Count remaining backups
BACKUP_COUNT=$(ls -1 $BACKUP_DIR/*.gz 2>/dev/null | wc -l)
print_status "Backup retention: $BACKUP_COUNT backup sets remaining"

# Verify backup integrity
print_status "Verifying backup integrity..."
if gzip -t $BACKUP_DIR/db_backup_$DATE.sql.gz 2>/dev/null; then
    print_status "✅ Database backup integrity verified"
else
    print_error "❌ Database backup corruption detected!"
    exit 1
fi

if tar -tzf $BACKUP_DIR/files_backup_$DATE.tar.gz >/dev/null 2>&1; then
    print_status "✅ Files backup integrity verified"
else
    print_warning "⚠️  Files backup verification failed or no files to backup"
fi

# Generate backup report
TOTAL_SIZE=$(du -sh $BACKUP_DIR | cut -f1)
cat > $BACKUP_DIR/backup_report_$DATE.txt << EOF
JustClik AI v2 Backup Report
============================
Date: $(date)
Backup ID: $DATE

Files Created:
- Database: db_backup_$DATE.sql.gz ($DB_SIZE)
- Files: files_backup_$DATE.tar.gz ($FILES_SIZE)
- Config: config_backup_$DATE.tar.gz ($CONFIG_SIZE)

Total Backup Directory Size: $TOTAL_SIZE
Retention Policy: $RETENTION_DAYS days
Backup Sets Retained: $BACKUP_COUNT

Status: SUCCESS
EOF

print_status "✅ Backup completed successfully!"
print_status "Backup report saved: backup_report_$DATE.txt"
print_status "📊 Total backup directory size: $TOTAL_SIZE"

# Optional: Send backup notification (uncomment if you want email notifications)
# echo "JustClik AI v2 backup completed successfully at $(date)" | mail -s "Backup Success" admin@yourdomain.com