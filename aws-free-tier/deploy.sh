#!/bin/bash

# ============================================
# AWS Free Tier Infrastructure Deployment
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI not found. Please install it first."
        exit 1
    fi
    print_success "AWS CLI installed"
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform not found. Please install it first."
        exit 1
    fi
    print_success "Terraform installed"
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Run 'aws configure'"
        exit 1
    fi
    print_success "AWS credentials configured"
    
    # Display account info
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REGION=$(aws configure get region)
    print_info "Account ID: $ACCOUNT_ID"
    print_info "Region: $REGION"
}

# Install Lambda dependencies
install_lambda_deps() {
    print_header "Installing Lambda Dependencies"
    
    cd lambda
    
    if [ -f "package.json" ]; then
        npm install
        print_success "Lambda dependencies installed"
    fi
    
    cd ..
}

# Initialize Terraform
init_terraform() {
    print_header "Initializing Terraform"
    
    cd terraform
    terraform init
    print_success "Terraform initialized"
    cd ..
}

# Plan Terraform deployment
plan_terraform() {
    print_header "Planning Terraform Deployment"
    
    cd terraform
    terraform plan -out=tfplan
    print_success "Terraform plan created"
    cd ..
}

# Apply Terraform deployment
apply_terraform() {
    print_header "Applying Terraform Deployment"
    
    cd terraform
    terraform apply tfplan
    print_success "Infrastructure deployed!"
    cd ..
}

# Get outputs
get_outputs() {
    print_header "Deployment Outputs"
    
    cd terraform
    
    WEBSITE_URL=$(terraform output -raw cloudfront_url 2>/dev/null || echo "N/A")
    API_URL=$(terraform output -raw visitor_counter_api 2>/dev/null || echo "N/A")
    BUCKET_NAME=$(terraform output -raw website_bucket_name 2>/dev/null || echo "N/A")
    
    echo ""
    print_success "Website URL: $WEBSITE_URL"
    print_success "API Endpoint: $API_URL"
    print_success "S3 Bucket: $BUCKET_NAME"
    echo ""
    
    # Save outputs to file
    cat > ../deployment-info.txt <<EOF
AWS Free Tier Deployment - $(date)
=====================================

Website URL: $WEBSITE_URL
API Endpoint: $API_URL
S3 Bucket: $BUCKET_NAME

Next Steps:
1. Update website/index.html with your API endpoint
2. Upload website files: ./deploy.sh upload
3. Visit your website at: $WEBSITE_URL

Cost: \$0.00 (Free Tier)
EOF
    
    print_info "Outputs saved to deployment-info.txt"
    cd ..
}

# Upload website files
upload_website() {
    print_header "Uploading Website Files"
    
    cd terraform
    BUCKET_NAME=$(terraform output -raw website_bucket_name 2>/dev/null)
    cd ..
    
    if [ -z "$BUCKET_NAME" ]; then
        print_error "Bucket name not found. Deploy infrastructure first."
        exit 1
    fi
    
    # Upload files
    aws s3 sync website/ s3://$BUCKET_NAME/ --delete
    print_success "Website files uploaded to S3"
    
    # Invalidate CloudFront cache
    cd terraform
    DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null)
    cd ..
    
    if [ ! -z "$DISTRIBUTION_ID" ]; then
        aws cloudfront create-invalidation \
            --distribution-id $DISTRIBUTION_ID \
            --paths "/*"
        print_success "CloudFront cache invalidated"
    fi
}

# Destroy infrastructure
destroy_infrastructure() {
    print_header "Destroying Infrastructure"
    
    read -p "Are you sure you want to destroy all resources? (yes/no): " confirm
    
    if [ "$confirm" = "yes" ]; then
        cd terraform
        terraform destroy -auto-approve
        print_success "Infrastructure destroyed"
        cd ..
    else
        print_info "Destruction cancelled"
    fi
}

# Show help
show_help() {
    cat <<EOF
AWS Free Tier Infrastructure Deployment Script

Usage: ./deploy.sh [command]

Commands:
  deploy      - Full deployment (check, install, plan, apply)
  plan        - Show deployment plan without applying
  apply       - Apply the deployment plan
  upload      - Upload website files to S3
  outputs     - Display deployment outputs
  destroy     - Destroy all infrastructure
  help        - Show this help message

Examples:
  ./deploy.sh deploy    # Full deployment
  ./deploy.sh upload    # Upload website after updating files
  ./deploy.sh destroy   # Clean up all resources
EOF
}

# Main script
main() {
    case "$1" in
        deploy)
            check_prerequisites
            install_lambda_deps
            init_terraform
            plan_terraform
            apply_terraform
            get_outputs
            echo ""
            print_info "Run './deploy.sh upload' to upload website files"
            ;;
        plan)
            check_prerequisites
            install_lambda_deps
            init_terraform
            plan_terraform
            ;;
        apply)
            cd terraform
            terraform apply
            cd ..
            get_outputs
            ;;
        upload)
            upload_website
            ;;
        outputs)
            get_outputs
            ;;
        destroy)
            destroy_infrastructure
            ;;
        help|--help|-h|"")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
