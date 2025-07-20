#!/bin/bash

# JustClik AI v2 - Health Check Script
# Monitors system health and sends alerts if issues detected

# Configuration
DOMAIN="justinemortgagequeen.justclik.ca"
LOG_FILE="/opt/justclik-ai/logs/health-check.log"
ALERT_EMAIL="" # Set email if you want alerts

# Colors (for terminal output)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Ensure log directory exists
mkdir -p /opt/justclik-ai/logs

# Function to log with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Function to send alert (if email configured)
send_alert() {
    local message="$1"
    log "ALERT: $message"
    
    if [ -n "$ALERT_EMAIL" ]; then
        echo "JustClik AI v2 Health Alert: $message" | mail -s "JustClik AI Alert" $ALERT_EMAIL
    fi
}

# Check if containers are running
check_containers() {
    local status=0
    
    if docker compose ps | grep -q "justine_mortgage_ai.*Up"; then
        log "✅ LibreChat container is running"
    else
        send_alert "❌ LibreChat container is down"
        status=1
    fi
    
    if docker compose ps | grep -q "justine_mortgage_db.*Up"; then
        log "✅ PostgreSQL container is running"
    else
        send_alert "❌ PostgreSQL container is down"
        status=1
    fi
    
    return $status
}

# Check HTTPS endpoint
check_https() {
    if curl -f -s -o /dev/null --max-time 10 https://$DOMAIN/health; then
        log "✅ HTTPS endpoint is accessible"
        return 0
    else
        send_alert "❌ HTTPS endpoint is not accessible"
        return 1
    fi
}

# Check disk space
check_disk_space() {
    local alert_threshold=80
    local warning_threshold=70
    
    df -h | grep -E '^/dev/' | awk '{ print $5 " " $1 }' | while read output; do
        usage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)
        partition=$(echo $output | awk '{ print $2}')
        
        if [ $usage -ge $alert_threshold ]; then
            send_alert "⚠️ Disk usage critical: $usage% on $partition"
        elif [ $usage -ge $warning_threshold ]; then
            log "⚠️ Disk usage warning: $usage% on $partition"
        fi
    done
}

# Check memory usage
check_memory() {
    local memory_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    local alert_threshold=85
    local warning_threshold=75
    
    if [ $memory_usage -ge $alert_threshold ]; then
        send_alert "⚠️ Memory usage critical: ${memory_usage}%"
    elif [ $memory_usage -ge $warning_threshold ]; then
        log "⚠️ Memory usage warning: ${memory_usage}%"
    else
        log "✅ Memory usage normal: ${memory_usage}%"
    fi
}

# Check SSL certificate expiration
check_ssl_expiry() {
    local cert_file="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
    
    if [ -f "$cert_file" ]; then
        local expiry_date=$(openssl x509 -enddate -noout -in "$cert_file" | cut -d= -f2)
        local expiry_epoch=$(date -d "$expiry_date" +%s)
        local current_epoch=$(date +%s)
        local days_until_expiry=$(( (expiry_epoch - current_epoch) / 86400 ))
        
        if [ $days_until_expiry -le 7 ]; then
            send_alert "⚠️ SSL certificate expires in $days_until_expiry days"
        elif [ $days_until_expiry -le 30 ]; then
            log "⚠️ SSL certificate expires in $days_until_expiry days"
        else
            log "✅ SSL certificate valid for $days_until_expiry days"
        fi
    else
        send_alert "❌ SSL certificate file not found"
    fi
}

# Check Docker daemon
check_docker() {
    if systemctl is-active --quiet docker; then
        log "✅ Docker daemon is running"
        return 0
    else
        send_alert "❌ Docker daemon is not running"
        return 1
    fi
}

# Check database connectivity
check_database() {
    if docker exec justine_mortgage_db pg_isready -U librechat > /dev/null 2>&1; then
        log "✅ Database is responding"
        return 0
    else
        send_alert "❌ Database is not responding"
        return 1
    fi
}

# Check log file sizes (prevent log files from growing too large)
check_log_sizes() {
    local max_size_mb=100
    
    find /opt/justclik-ai/logs -name "*.log" -size +${max_size_mb}M | while read logfile; do
        log "⚠️ Large log file detected: $logfile"
        # Optionally rotate the log
        # mv "$logfile" "${logfile}.old"
        # touch "$logfile"
    done
}

# Main health check routine
main() {
    local overall_status=0
    
    log "Starting health check..."
    
    check_docker || overall_status=1
    check_containers || overall_status=1
    check_https || overall_status=1
    check_database || overall_status=1
    check_disk_space
    check_memory
    check_ssl_expiry
    check_log_sizes
    
    if [ $overall_status -eq 0 ]; then
        log "✅ Health check completed - All systems operational"
    else
        log "❌ Health check completed - Issues detected"
    fi
    
    # Keep only last 1000 lines of health check log
    tail -n 1000 $LOG_FILE > ${LOG_FILE}.tmp && mv ${LOG_FILE}.tmp $LOG_FILE
    
    return $overall_status
}

# Run the health check
main

# Exit with the overall status
exit $?