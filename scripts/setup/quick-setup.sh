#!/bin/bash
################################################################################
# Script: quick-setup.sh
# Description: Quick setup script to organize repository structure
# Author: QUOJO DAWSON
# Usage: ./quick-setup.sh
################################################################################

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

function log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

function log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

function log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  DevOps Practice Repository - Quick Setup Script              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

log_info "Creating directory structure..."

# Create all necessary directories
directories=(
    "docs"
    "scripts/setup"
    "scripts/deployment"
    "scripts/monitoring"
    "scripts/automation"
    "scripts/security"
    "ci-cd/jenkins"
    "ci-cd/github-actions"
    "ci-cd/gitlab-ci"
    "infrastructure/terraform/aws/modules"
    "infrastructure/terraform/aws/environments"
    "infrastructure/ansible/playbooks"
    "infrastructure/ansible/roles"
    "infrastructure/kubernetes/base"
    "infrastructure/kubernetes/overlays/dev"
    "infrastructure/kubernetes/overlays/staging"
    "infrastructure/kubernetes/overlays/production"
    "infrastructure/kubernetes/helm"
    "docker"
    "tests/unit"
    "tests/integration"
    "tests/e2e"
    "examples/simple-deployment"
    "examples/microservices"
    "monitoring/prometheus"
    "monitoring/grafana/dashboards"
    "monitoring/elk"
    ".github/workflows"
    "assets/images"
    "backups"
)

for dir in "${directories[@]}"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_success "Created: $dir"
    else
        log_warn "Already exists: $dir"
    fi
done

log_info "Creating placeholder files..."

# Create placeholder files
placeholders=(
    "docs/architecture.md"
    "docs/best-practices.md"
    "docs/troubleshooting.md"
    "scripts/setup/check-prerequisites.sh"
    "scripts/setup/install-tools.sh"
    "scripts/deployment/deploy-local.sh"
    "scripts/deployment/rollback.sh"
    "scripts/monitoring/setup-prometheus.sh"
    "scripts/monitoring/health-check.sh"
    "scripts/automation/backup.sh"
    "scripts/automation/cleanup.sh"
    "scripts/security/scan-vulnerabilities.sh"
    ".github/workflows/.gitkeep"
    "tests/.gitkeep"
    "examples/.gitkeep"
)

for file in "${placeholders[@]}"; do
    if [[ ! -f "$file" ]]; then
        touch "$file"
        log_success "Created: $file"
    fi
done

# Make scripts executable
log_info "Making scripts executable..."
find scripts -name "*.sh" -type f -exec chmod +x {} \;
log_success "Scripts are now executable"

# Create .env.example if it doesn't exist
if [[ ! -f ".env.example" ]]; then
    log_info "Creating .env.example..."
    cat > .env.example << 'EOF'
# AWS Configuration
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012
EKS_CLUSTER_DEV=dev-cluster
EKS_CLUSTER_STAGING=staging-cluster
EKS_CLUSTER_PROD=prod-cluster

# Docker Registry
DOCKER_REGISTRY=docker.io
DOCKER_USERNAME=your-username

# Database Configuration
DATABASE_HOST=localhost
DATABASE_NAME=appdb
DATABASE_USER=dbuser
DATABASE_PASSWORD=changeme

# Monitoring
PROMETHEUS_URL=http://prometheus:9090
GRAFANA_URL=http://grafana:3000

# Notifications
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Application
NODE_ENV=development
PORT=3000
EOF
    log_success "Created .env.example"
fi

# Create basic .gitignore if it doesn't exist
if [[ ! -f ".gitignore" ]]; then
    log_info "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Environment
.env
.env.local
*.env

# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Node
node_modules/
npm-debug.log*

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Secrets
secrets/
*.pem
*.key

# Backups
backups/
*.backup
EOF
    log_success "Created .gitignore"
fi

echo ""
log_success "Directory structure created successfully!"
echo ""
echo "Next steps:"
echo "  1. Copy your files to the appropriate directories"
echo "  2. Review and update .env.example with your configuration"
echo "  3. Add your scripts to the scripts/ directories"
echo "  4. Update documentation in docs/"
echo "  5. Run: git status to see new files"
echo "  6. Run: git add . to stage all changes"
echo ""
log_info "For detailed implementation steps, see: IMPLEMENTATION_GUIDE.md"
