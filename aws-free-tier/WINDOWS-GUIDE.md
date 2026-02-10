# 🪟 Windows Quick Start Guide

Quick start guide for deploying AWS infrastructure from Windows.

## 📋 Prerequisites for Windows

### 1. Install Required Tools

#### AWS CLI
```powershell
# Download and install from:
# https://awscli.amazonaws.com/AWSCLIV2.msi

# Verify installation
aws --version
```

#### Terraform
```powershell
# Download from: https://www.terraform.io/downloads

# Or use Chocolatey:
choco install terraform

# Verify installation
terraform --version
```

#### Node.js
```powershell
# Download from: https://nodejs.org/

# Or use Chocolatey:
choco install nodejs

# Verify installation
node --version
npm --version
```

#### Git Bash (Recommended)
```powershell
# Download from: https://git-scm.com/download/win

# This provides a Unix-like environment for running bash scripts
```

## 🚀 Deployment Steps (Windows)

### Option A: Using Git Bash (Recommended)

1. **Open Git Bash**
2. **Navigate to project**
   ```bash
   cd /c/Users/dawso/devops-practise
   mkdir aws-free-tier
   cd aws-free-tier
   # Copy all project files here
   ```

3. **Run deployment script**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh deploy
   ```

### Option B: Using PowerShell

1. **Open PowerShell as Administrator**

2. **Navigate to project**
   ```powershell
   cd C:\Users\dawso\devops-practise
   mkdir aws-free-tier
   cd aws-free-tier
   # Copy all project files here
   ```

3. **Install Lambda dependencies**
   ```powershell
   cd lambda
   npm install
   cd ..
   ```

4. **Deploy with Terraform**
   ```powershell
   cd terraform
   
   # Initialize
   terraform init
   
   # Plan
   terraform plan -out=tfplan
   
   # Apply
   terraform apply tfplan
   
   # Get outputs
   terraform output
   
   cd ..
   ```

5. **Update website with API endpoint**
   ```powershell
   # Edit website/index.html in notepad
   notepad website\index.html
   
   # Replace: YOUR_API_GATEWAY_ENDPOINT_HERE
   # With the API URL from terraform output
   ```

6. **Upload website files**
   ```powershell
   # Get bucket name from terraform output
   $BUCKET = terraform output -raw website_bucket_name
   
   # Upload files
   aws s3 sync website\ s3://$BUCKET/ --delete
   
   # Invalidate CloudFront
   $DIST_ID = terraform output -raw cloudfront_distribution_id
   aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
   ```

## 📝 PowerShell Deployment Script

Save this as `deploy.ps1`:

```powershell
# deploy.ps1 - Windows deployment script

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('deploy','plan','apply','upload','outputs','destroy')]
    [string]$Command = 'help'
)

function Write-Header {
    param([string]$Message)
    Write-Host "`n============================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "============================================`n" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Yellow
}

function Check-Prerequisites {
    Write-Header "Checking Prerequisites"
    
    # Check AWS CLI
    if (!(Get-Command aws -ErrorAction SilentlyContinue)) {
        Write-Error "AWS CLI not found"
        exit 1
    }
    Write-Success "AWS CLI installed"
    
    # Check Terraform
    if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
        Write-Error "Terraform not found"
        exit 1
    }
    Write-Success "Terraform installed"
    
    # Check AWS credentials
    try {
        aws sts get-caller-identity | Out-Null
        Write-Success "AWS credentials configured"
    } catch {
        Write-Error "AWS credentials not configured"
        exit 1
    }
    
    # Display account info
    $accountId = aws sts get-caller-identity --query Account --output text
    $region = aws configure get region
    Write-Info "Account ID: $accountId"
    Write-Info "Region: $region"
}

function Install-LambdaDeps {
    Write-Header "Installing Lambda Dependencies"
    
    Push-Location lambda
    npm install
    Write-Success "Lambda dependencies installed"
    Pop-Location
}

function Initialize-Terraform {
    Write-Header "Initializing Terraform"
    
    Push-Location terraform
    terraform init
    Write-Success "Terraform initialized"
    Pop-Location
}

function New-TerraformPlan {
    Write-Header "Planning Terraform Deployment"
    
    Push-Location terraform
    terraform plan -out=tfplan
    Write-Success "Terraform plan created"
    Pop-Location
}

function Deploy-Terraform {
    Write-Header "Applying Terraform Deployment"
    
    Push-Location terraform
    terraform apply tfplan
    Write-Success "Infrastructure deployed!"
    Pop-Location
}

function Get-DeploymentOutputs {
    Write-Header "Deployment Outputs"
    
    Push-Location terraform
    
    $websiteUrl = terraform output -raw cloudfront_url 2>$null
    $apiUrl = terraform output -raw visitor_counter_api 2>$null
    $bucketName = terraform output -raw website_bucket_name 2>$null
    
    Write-Host ""
    Write-Success "Website URL: $websiteUrl"
    Write-Success "API Endpoint: $apiUrl"
    Write-Success "S3 Bucket: $bucketName"
    Write-Host ""
    
    # Save outputs
    @"
AWS Free Tier Deployment - $(Get-Date)
=====================================

Website URL: $websiteUrl
API Endpoint: $apiUrl
S3 Bucket: $bucketName

Next Steps:
1. Update website/index.html with your API endpoint
2. Upload website files: .\deploy.ps1 upload
3. Visit your website at: $websiteUrl

Cost: `$0.00 (Free Tier)
"@ | Out-File -FilePath ..\deployment-info.txt -Encoding UTF8
    
    Write-Info "Outputs saved to deployment-info.txt"
    Pop-Location
}

function Upload-Website {
    Write-Header "Uploading Website Files"
    
    Push-Location terraform
    $bucketName = terraform output -raw website_bucket_name 2>$null
    $distId = terraform output -raw cloudfront_distribution_id 2>$null
    Pop-Location
    
    if (!$bucketName) {
        Write-Error "Bucket name not found. Deploy infrastructure first."
        exit 1
    }
    
    # Upload files
    aws s3 sync website\ s3://$bucketName/ --delete
    Write-Success "Website files uploaded to S3"
    
    # Invalidate CloudFront
    if ($distId) {
        aws cloudfront create-invalidation --distribution-id $distId --paths "/*"
        Write-Success "CloudFront cache invalidated"
    }
}

function Remove-Infrastructure {
    Write-Header "Destroying Infrastructure"
    
    $confirm = Read-Host "Are you sure you want to destroy all resources? (yes/no)"
    
    if ($confirm -eq 'yes') {
        Push-Location terraform
        terraform destroy -auto-approve
        Write-Success "Infrastructure destroyed"
        Pop-Location
    } else {
        Write-Info "Destruction cancelled"
    }
}

function Show-Help {
    @"
AWS Free Tier Infrastructure Deployment Script (Windows)

Usage: .\deploy.ps1 [command]

Commands:
  deploy      - Full deployment (check, install, plan, apply)
  plan        - Show deployment plan without applying
  apply       - Apply the deployment plan
  upload      - Upload website files to S3
  outputs     - Display deployment outputs
  destroy     - Destroy all infrastructure
  help        - Show this help message

Examples:
  .\deploy.ps1 deploy    # Full deployment
  .\deploy.ps1 upload    # Upload website after updating files
  .\deploy.ps1 destroy   # Clean up all resources
"@
}

# Main script
switch ($Command) {
    'deploy' {
        Check-Prerequisites
        Install-LambdaDeps
        Initialize-Terraform
        New-TerraformPlan
        Deploy-Terraform
        Get-DeploymentOutputs
        Write-Host ""
        Write-Info "Run '.\deploy.ps1 upload' to upload website files"
    }
    'plan' {
        Check-Prerequisites
        Install-LambdaDeps
        Initialize-Terraform
        New-TerraformPlan
    }
    'apply' {
        Push-Location terraform
        terraform apply
        Pop-Location
        Get-DeploymentOutputs
    }
    'upload' {
        Upload-Website
    }
    'outputs' {
        Get-DeploymentOutputs
    }
    'destroy' {
        Remove-Infrastructure
    }
    default {
        Show-Help
    }
}
```

## 🔧 Configure AWS CLI

```powershell
# Run configuration wizard
aws configure

# Enter when prompted:
# AWS Access Key ID: [Your access key]
# AWS Secret Access Key: [Your secret key]
# Default region name: us-east-2
# Default output format: json
```

## ✅ Verify Setup

```powershell
# Test AWS connection
aws sts get-caller-identity

# Should output:
# {
#     "UserId": "...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/quojo-admin"
# }
```

## 📂 File Organization

Copy files to your devops-practise repo:

```powershell
cd C:\Users\dawso\devops-practise
mkdir aws-free-tier
cd aws-free-tier

# Create subdirectories
mkdir terraform
mkdir lambda
mkdir website

# Copy files to respective folders:
# terraform/* → terraform/
# lambda/* → lambda/
# website/* → website/
# *.sh, *.ps1, README.md → root
```

## 🚀 Quick Deploy

```powershell
# All-in-one deployment
.\deploy.ps1 deploy

# Or step-by-step:
.\deploy.ps1 plan     # Review changes
.\deploy.ps1 apply    # Deploy infrastructure
.\deploy.ps1 outputs  # View URLs
.\deploy.ps1 upload   # Upload website
```

## 💡 Tips for Windows Users

1. **Use Git Bash** for running `.sh` scripts
2. **Use PowerShell** for `deploy.ps1` script
3. **Run as Administrator** if you get permission errors
4. **Check Windows Defender** if downloads are blocked
5. **Use full paths** if relative paths don't work

## 🐛 Common Windows Issues

### Issue: "terraform: command not found"
**Solution:** Add Terraform to PATH or use full path

### Issue: "Access Denied" errors
**Solution:** Run PowerShell as Administrator

### Issue: "npm: command not found"
**Solution:** Restart terminal after installing Node.js

### Issue: Line ending errors in bash scripts
**Solution:** Convert CRLF to LF:
```bash
dos2unix deploy.sh
```

## 📞 Need Help?

If you encounter issues:
1. Check AWS CloudWatch logs
2. Verify AWS credentials: `aws sts get-caller-identity`
3. Check Terraform state: `terraform show`
4. Review error messages carefully

---

**You're all set!** Ready to deploy your AWS infrastructure from Windows! 🚀
