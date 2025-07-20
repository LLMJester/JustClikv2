# JustClik AI Platform - Complete Implementation Specification

## Project Overview
**Project Name:** JustClik AI - Canadian Mortgage Intelligence Platform  
**Client:** Justine Mortgage Queen  
**URL:** justinemortgagequeen.justclik.ca  
**Version:** 1.0  
**Last Updated:** 2025-01-14  
**Build Timeline:** Tonight (4-6 hours)

---

## 1. Complete Technology Stack

### 1.1 Infrastructure Layer
- **Cloud Provider:** Canadian Cloud Hosting (CACloud.com)
  - Product: Enterprise VM30
  - Location: Toronto Datacenter
  - Certifications: SOC 2 Type 2, SSAE 16
  - Price: $75/month
  - Specs: 2vCPU, 4GB RAM, 75GB Storage, 10TB Bandwidth

### 1.2 Operating System & Runtime
- **OS:** Ubuntu 22.04 LTS
- **Container Runtime:** Docker Engine (latest stable)
- **Container Orchestration:** Docker Compose v3.8
- **Reverse Proxy:** Nginx 1.24+
- **SSL Provider:** Let's Encrypt (Certbot)

### 1.3 Application Platform
- **Core Platform:** LibreChat (latest release)
  - GitHub: danny-avila/LibreChat
  - License: MIT (commercial use allowed)
  - Docker Image: ghcr.io/danny-avila/LibreChat:latest

### 1.4 AI Provider
- **Primary AI:** Cohere (Canadian)
  - Endpoint: api.cohere.ai
  - Model: command-r (latest)
  - Pricing: ~$0.001 per token
  - Data Location: Canada

### 1.5 Database & Storage
- **Database:** PostgreSQL 15
  - Container: postgres:15-alpine
  - Storage: Persistent Docker volume
  - Backup: Daily automated
- **File Storage:** Docker volumes
  - User uploads: /app/backend/data/uploads
  - Configurations: /app/backend/data/config

### 1.6 Authentication & Security
- **Authentication:** LibreChat built-in auth system
  - JWT-based sessions
  - Bcrypt password hashing
  - Email/password registration
- **Security:**
  - HTTPS enforced (SSL/TLS 1.3)
  - CORS properly configured
  - Rate limiting enabled
  - Session timeout: 30 minutes idle

---

## 2. Feature Specifications

### 2.1 Agent System Configuration
```yaml
# Mortgage Assistant Agent Configuration
agent:
  id: "mortgage-assistant-001"
  name: "Justine's Mortgage Assistant"
  description: "Expert Canadian mortgage advisor AI"
  model: "command-r"
  temperature: 0.7
  
  capabilities:
    file_search: true
    file_upload: true
    web_search: true
    code_interpreter: true
    
  tools:
    - name: "web_search"
      description: "Search current mortgage rates"
    - name: "calculator"
      description: "Mortgage payment calculations"
    - name: "document_analyzer"
      description: "Extract data from uploaded documents"
    - name: "rate_scraper"
      description: "Check lender websites for rates"
      
  system_prompt: |
    You are Justine's Mortgage Assistant, an expert in Canadian mortgages.
    
    Your capabilities:
    - Analyze client financial documents
    - Search current mortgage rates from Canadian lenders
    - Calculate mortgage payments and affordability
    - Match clients with appropriate lenders
    - Generate professional mortgage summaries
    
    Guidelines:
    - Always maintain client confidentiality
    - Provide accurate, current Canadian mortgage information
    - Focus on major Canadian lenders (TD, RBC, BMO, Scotiabank, etc.)
    - Consider Canadian regulations (stress test, down payment rules)
    - Be helpful but remind clients to consult Justine for final advice
    
    You have access to uploaded files and can search the web for current rates.
```

### 2.2 File Upload Configuration
```javascript
// File upload settings
fileUpload: {
  enabled: true,
  maxFileSize: 10485760, // 10MB in bytes
  allowedTypes: [
    'application/pdf',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/csv',
    'image/jpeg',
    'image/png'
  ],
  uploadButton: {
    text: "JustClik to Upload",
    icon: "📎",
    className: "justclik-upload-btn"
  }
}
```

### 2.3 Custom Branding Configuration
```css
/* Custom CSS for Justine Mortgage Queen branding */
:root {
  --primary-color: #1e40af; /* Professional Blue */
  --secondary-color: #f59e0b; /* Trust Gold */
  --accent-color: #059669; /* Success Green */
  --text-primary: #111827;
  --background: #f9fafb;
}

/* JustClik Upload Button */
.justclik-upload-btn {
  background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
  color: white;
  font-weight: bold;
  padding: 12px 24px;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.justclik-upload-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
}

/* Custom Header */
.app-header {
  background: var(--primary-color);
  padding: 16px;
}

.brand-logo {
  height: 40px;
  margin-right: 16px;
}

/* Custom Footer */
.app-footer {
  text-align: center;
  padding: 20px;
  background: var(--background);
  border-top: 1px solid #e5e7eb;
}

.footer-text {
  color: var(--text-primary);
  font-size: 14px;
}
```

### 2.4 Environment Configuration
```env
# .env file configuration
# Domain Configuration
DOMAIN=justinemortgagequeen.justclik.ca
APP_TITLE=Justine Mortgage Queen AI Assistant

# AI Configuration
ENDPOINTS=agents
COHERE_API_KEY=your_cohere_api_key_here
COHERE_MODELS=command-r,command-r-plus

# Security
JWT_SECRET=generate_32_char_random_string
SESSION_SECRET=generate_32_char_random_string
CREDS_KEY=generate_32_char_random_string
CREDS_IV=generate_16_char_random_string

# Database
DATABASE_URL=postgresql://librechat:secure_password@postgres:5432/librechat

# Features
REGISTRATION_OPEN=false
ALLOW_SOCIAL_LOGIN=false
ALLOW_ACCOUNT_DELETION=true
ALLOW_FILE_UPLOADS=true

# Branding
CUSTOM_FOOTER="Powered by JustClik | Secured by Canadian SOC 2 Infrastructure | Data Never Leaves Canada"
BRAND_LOGO_URL=/assets/custom/justine-logo.png
BRAND_LOGO_CHAT=/assets/custom/justine-logo-small.png

# Canadian Compliance
DATA_RETENTION=indefinite
USER_CONTROLLED_DELETION=true
COMPLIANCE_MODE=PIPEDA
```

---

## 3. Complete Deployment Guide

### 3.1 Server Setup Commands
```bash
#!/bin/bash
# Complete server setup script

# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    git \
    nginx \
    certbot \
    python3-certbot-nginx

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Create project directory
mkdir -p /opt/justclik-ai
cd /opt/justclik-ai
```

### 3.2 Docker Compose Configuration
```yaml
# docker-compose.yml
version: '3.8'

services:
  librechat:
    image: ghcr.io/danny-avila/LibreChat:latest
    container_name: justine_mortgage_ai
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - DOMAIN=${DOMAIN}
      - APP_TITLE=${APP_TITLE}
      - ENDPOINTS=${ENDPOINTS}
      - COHERE_API_KEY=${COHERE_API_KEY}
      - COHERE_MODELS=${COHERE_MODELS}
      - JWT_SECRET=${JWT_SECRET}
      - SESSION_SECRET=${SESSION_SECRET}
      - CREDS_KEY=${CREDS_KEY}
      - CREDS_IV=${CREDS_IV}
      - DATABASE_URL=${DATABASE_URL}
      - REGISTRATION_OPEN=${REGISTRATION_OPEN}
      - ALLOW_FILE_UPLOADS=${ALLOW_FILE_UPLOADS}
      - CUSTOM_FOOTER=${CUSTOM_FOOTER}
    volumes:
      - ./data:/app/backend/data
      - ./logs:/app/backend/logs
      - ./branding:/app/client/public/assets/custom
      - ./config/librechat.yaml:/app/librechat.yaml
    depends_on:
      - postgres
    networks:
      - justclik-network

  postgres:
    image: postgres:15-alpine
    container_name: justine_mortgage_db
    restart: unless-stopped
    environment:
      - POSTGRES_DB=librechat
      - POSTGRES_USER=librechat
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups
    networks:
      - justclik-network

networks:
  justclik-network:
    driver: bridge

volumes:
  postgres_data:
```

### 3.3 Nginx Configuration
```nginx
# /etc/nginx/sites-available/justinemortgagequeen
server {
    listen 80;
    server_name justinemortgagequeen.justclik.ca;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name justinemortgagequeen.justclik.ca;

    # SSL configuration will be added by Certbot
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self' https:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; style-src 'self' 'unsafe-inline' https:;" always;

    # Proxy settings
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_read_timeout 86400;
    }
    
    # File upload size
    client_max_body_size 10M;
}
```

### 3.4 LibreChat Configuration
```yaml
# config/librechat.yaml
version: 1.0.0

cache:
  redis:
    enabled: false

fileStrategy:
  type: local
  maxFileSize: 10485760
  supportedMimeTypes:
    - application/pdf
    - application/vnd.ms-excel
    - application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    - application/msword
    - application/vnd.openxmlformats-officedocument.wordprocessingml.document
    - text/csv
    - image/jpeg
    - image/png

agents:
  enabled: true
  capabilities:
    - file_search
    - file_upload
    - web_search
    - code_interpreter
  
  presets:
    - id: mortgage-assistant
      name: "Justine's Mortgage Assistant"
      description: "Expert Canadian mortgage advisor"
      model: command-r
      tools:
        - web_search
        - file_search
        - calculator
      systemPrompt: |
        You are Justine's Mortgage Assistant, an expert in Canadian mortgages...

endpoints:
  agents:
    enabled: true
    models:
      - command-r
      - command-r-plus
```

---

## 4. Step-by-Step Deployment Checklist

### Phase 1: CACloud Setup (30 minutes)
- [ ] Sign up at CACloud.com
- [ ] Order Enterprise VM30 (Toronto)
- [ ] Note down server IP address
- [ ] SSH into server: `ssh root@YOUR_IP`

### Phase 2: DNS Configuration (15 minutes)
- [ ] Go to domain registrar
- [ ] Add A record: justinemortgagequeen → Server IP
- [ ] Wait for DNS propagation (5-15 minutes)

### Phase 3: Server Setup (45 minutes)
- [ ] Run system update commands
- [ ] Install Docker and dependencies
- [ ] Create project directory structure
- [ ] Upload configuration files

### Phase 4: SSL Certificate (15 minutes)
- [ ] Enable Nginx site configuration
- [ ] Run Certbot: `sudo certbot --nginx -d justinemortgagequeen.justclik.ca`
- [ ] Verify HTTPS is working

### Phase 5: Deploy LibreChat (30 minutes)
- [ ] Create .env file with all variables
- [ ] Pull Docker images
- [ ] Start containers: `docker compose up -d`
- [ ] Verify application is running

### Phase 6: Configuration (45 minutes)
- [ ] Access LibreChat at https://justinemortgagequeen.justclik.ca
- [ ] Create admin account
- [ ] Configure Cohere API
- [ ] Create Mortgage Assistant agent
- [ ] Test file uploads
- [ ] Apply custom branding

### Phase 7: Testing (30 minutes)
- [ ] Test agent conversations
- [ ] Upload test documents
- [ ] Verify web search works
- [ ] Test mortgage calculations
- [ ] Check Canadian data residency

### Phase 8: Client Handoff (30 minutes)
- [ ] Create Justine's user account
- [ ] Quick training on agent usage
- [ ] Demonstrate file upload
- [ ] Provide documentation
- [ ] Get feedback

---

## 5. Monitoring & Maintenance

### 5.1 Health Check Script
```bash
#!/bin/bash
# monitoring/health-check.sh

# Check if containers are running
docker ps | grep justine_mortgage_ai > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ LibreChat container is running"
else
    echo "❌ LibreChat container is down"
    # Send alert
fi

# Check HTTPS endpoint
curl -s https://justinemortgagequeen.justclik.ca > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ HTTPS endpoint is accessible"
else
    echo "❌ HTTPS endpoint is down"
fi

# Check disk space
df -h | grep -E '^/dev/' | awk '{ print $5 " " $1 }' | while read output;
do
  usage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)
  if [ $usage -ge 80 ]; then
    echo "⚠️  Disk usage is above 80%"
  fi
done
```

### 5.2 Backup Script
```bash
#!/bin/bash
# backup/daily-backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/justclik-ai/backups"

# Backup database
docker exec justine_mortgage_db pg_dump -U librechat librechat > $BACKUP_DIR/db_backup_$DATE.sql

# Backup uploaded files
tar -czf $BACKUP_DIR/files_backup_$DATE.tar.gz /opt/justclik-ai/data/uploads

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "✅ Backup completed: $DATE"
```

### 5.3 Update Script
```bash
#!/bin/bash
# maintenance/update-librechat.sh

# Pull latest image
docker pull ghcr.io/danny-avila/LibreChat:latest

# Backup before update
./backup/daily-backup.sh

# Restart containers with new image
cd /opt/justclik-ai
docker compose down
docker compose up -d

echo "✅ LibreChat updated to latest version"
```

---

## 6. Security Best Practices

### 6.1 Firewall Rules
```bash
# UFW firewall configuration
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
```

### 6.2 SSH Hardening
```bash
# Disable root login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Create admin user
sudo adduser justclik-admin
sudo usermod -aG sudo justclik-admin
```

### 6.3 Environment Security
```bash
# Secure .env file
chmod 600 /opt/justclik-ai/.env
chown root:root /opt/justclik-ai/.env
```

---

## 7. Troubleshooting Guide

### Common Issues and Solutions

**Issue: Container won't start**
```bash
# Check logs
docker logs justine_mortgage_ai
# Usually missing environment variables
```

**Issue: Can't upload files**
```bash
# Check permissions
docker exec justine_mortgage_ai ls -la /app/backend/data
# Fix permissions if needed
docker exec justine_mortgage_ai chown -R node:node /app/backend/data
```

**Issue: Cohere API not working**
```bash
# Test API key
curl -X POST https://api.cohere.ai/v1/generate \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello", "model": "command-r"}'
```

---

## 8. Cost Summary

### Monthly Recurring Costs
| Service | Provider | Cost (CAD) |
|---------|----------|------------|
| VM Hosting | CACloud | $75 |
| Domain | Existing | $0 |
| SSL Certificate | Let's Encrypt | $0 |
| Cohere API | Cohere | ~$50 (usage based) |
| **Total** | | **~$125/month** |

### One-Time Costs
| Item | Cost |
|------|------|
| Setup Time | 4-6 hours |
| Domain Config | $0 |
| Initial Testing | Included |

---

## 9. Legal & Compliance

### Required Legal Documents
1. **Privacy Policy** - Must mention:
   - Data stored in Canada
   - Cohere as AI processor
   - User rights under PIPEDA
   - Data retention policy

2. **Terms of Service** - Must include:
   - AI limitations disclaimer
   - No financial advice disclaimer
   - User responsibilities
   - Liability limitations

3. **Cookie Policy** - Must cover:
   - Session cookies
   - Authentication cookies
   - No tracking cookies

### Compliance Checklist
- [ ] All data stored in Toronto datacenter
- [ ] SSL/TLS encryption enabled
- [ ] User consent for data processing
- [ ] Clear AI limitations disclaimer
- [ ] No storage of raw SIN numbers
- [ ] User-controlled data deletion
- [ ] SOC 2 infrastructure verified

---

## 10. Success Criteria

### Launch Day Checklist
- [ ] Site accessible at https://justinemortgagequeen.justclik.ca
- [ ] SSL certificate shows as valid
- [ ] Admin account created
- [ ] Mortgage Assistant agent configured
- [ ] File upload tested with PDF
- [ ] Web search returning results
- [ ] Custom branding visible
- [ ] "JustClik" button working
- [ ] Cohere API connected
- [ ] Test conversation completed

### Performance Metrics
- Page load time: < 2 seconds
- Chat response time: < 3 seconds
- File upload time: < 5 seconds
- Uptime target: 99.9%

---

## Appendix A: Quick Commands Reference

```bash
# Start everything
cd /opt/justclik-ai && docker compose up -d

# Stop everything
cd /opt/justclik-ai && docker compose down

# View logs
docker logs -f justine_mortgage_ai

# Restart after config change
docker compose restart librechat

# Backup database
docker exec justine_mortgage_db pg_dump -U librechat librechat > backup.sql

# Enter container shell
docker exec -it justine_mortgage_ai sh

# Check disk usage
df -h

# Check container status
docker ps
```

---

## Appendix B: Emergency Contacts

- **CACloud Support:** [Include after signup]
- **Domain Registrar:** [Your registrar support]
- **Your GitHub:** [Your repository URL]
- **Cohere Support:** support@cohere.ai

---

*This specification contains everything needed to build and deploy the JustClik AI platform tonight. Follow the deployment checklist in order for best results.*