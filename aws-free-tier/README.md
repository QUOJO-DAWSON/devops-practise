# 🚀 AWS Free Tier Portfolio Infrastructure

Complete serverless infrastructure for a professional portfolio website using AWS Free Tier services. This project demonstrates production-ready DevOps practices with Infrastructure as Code.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Cost Information](#cost-information)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

## 🏗️ Architecture

```
┌─────────────┐
│   User      │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│   CloudFront CDN    │ (Global Distribution)
└──────────┬──────────┘
           │
           ▼
    ┌─────────────┐
    │  S3 Bucket  │ (Static Website)
    └─────────────┘

    ┌─────────────────────────┐
    │  API Gateway (HTTP)     │
    └───────────┬─────────────┘
                │
                ▼
         ┌──────────────┐
         │   Lambda     │ (Visitor Counter)
         └──────┬───────┘
                │
                ▼
         ┌──────────────┐
         │  DynamoDB    │ (Data Storage)
         └──────────────┘

    ┌─────────────────────────┐
    │  CloudWatch Dashboard   │ (Monitoring)
    └─────────────────────────┘
```

## ✨ Features

### Infrastructure
- ✅ **S3 Static Website Hosting** - Scalable, durable storage
- ✅ **CloudFront CDN** - Global content delivery with HTTPS
- ✅ **Lambda Function** - Serverless visitor counter
- ✅ **API Gateway** - RESTful API endpoints
- ✅ **DynamoDB** - NoSQL database for visitor count
- ✅ **CloudWatch Dashboard** - Real-time monitoring

### DevOps Practices
- ✅ **Infrastructure as Code** - Terraform configuration
- ✅ **Automated Deployment** - Bash scripts
- ✅ **Cost Optimization** - 100% Free Tier eligible
- ✅ **Security Best Practices** - IAM roles, least privilege
- ✅ **Monitoring & Logging** - CloudWatch integration
- ✅ **Production Ready** - Scalable architecture

## 📦 Prerequisites

### Required Tools
1. **AWS Account** (Free Tier eligible)
2. **AWS CLI** (configured with credentials)
3. **Terraform** (>= 1.0)
4. **Node.js** (for Lambda dependencies)
5. **Bash** (for deployment scripts)

### AWS CLI Configuration

```bash
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (us-east-2 recommended)
# - Default output format (json)
```

### Verify Setup

```bash
aws sts get-caller-identity  # Should show your account details
terraform --version          # Should show Terraform version
node --version               # Should show Node.js version
```

## 🚀 Quick Start

### 1. Clone or Download This Project

```bash
# If adding to existing repo
cd /path/to/your/repo
mkdir aws-free-tier
cd aws-free-tier

# Copy all project files here
```

### 2. Make Deployment Script Executable

```bash
chmod +x deploy.sh
```

### 3. Deploy Infrastructure

```bash
./deploy.sh deploy
```

This will:
- ✅ Check prerequisites
- ✅ Install Lambda dependencies
- ✅ Initialize Terraform
- ✅ Create deployment plan
- ✅ Deploy all infrastructure
- ✅ Display outputs

### 4. Update Website with API Endpoint

```bash
# Edit website/index.html
# Replace: YOUR_API_GATEWAY_ENDPOINT_HERE
# With the API URL from deployment outputs
```

### 5. Upload Website Files

```bash
./deploy.sh upload
```

### 6. Visit Your Website!

```bash
# Check deployment-info.txt for your CloudFront URL
cat deployment-info.txt
```

## 📚 Detailed Setup

### Step-by-Step Deployment

#### Step 1: Initialize Infrastructure

```bash
cd terraform
terraform init
```

Expected output:
```
Terraform has been successfully initialized!
```

#### Step 2: Review Deployment Plan

```bash
terraform plan
```

This shows all resources that will be created:
- S3 bucket for website
- CloudFront distribution
- Lambda function
- API Gateway
- DynamoDB table
- CloudWatch dashboard
- IAM roles and policies

#### Step 3: Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

Deployment time: ~5-10 minutes (CloudFront takes longest)

#### Step 4: Get Deployment Outputs

```bash
terraform output
```

Save these values:
- `website_url` - CloudFront URL for your site
- `visitor_counter_api` - API endpoint URL
- `website_bucket_name` - S3 bucket name

#### Step 5: Configure Website

Edit `website/index.html`:

```javascript
// Find this line:
const API_ENDPOINT = 'YOUR_API_GATEWAY_ENDPOINT_HERE/count';

// Replace with your actual endpoint:
const API_ENDPOINT = 'https://abc123.execute-api.us-east-2.amazonaws.com/count';
```

#### Step 6: Upload Website

```bash
cd ..
aws s3 sync website/ s3://YOUR-BUCKET-NAME/ --delete
```

Or use the deploy script:
```bash
./deploy.sh upload
```

#### Step 7: Invalidate CloudFront Cache

```bash
aws cloudfront create-invalidation \
    --distribution-id YOUR-DISTRIBUTION-ID \
    --paths "/*"
```

#### Step 8: Test Your Website

Visit your CloudFront URL:
```
https://d1234567890abc.cloudfront.net
```

The visitor counter should increment each time you refresh!

## 💰 Cost Information

### Free Tier Limits (12 months)

| Service | Free Tier | This Project Uses |
|---------|-----------|-------------------|
| S3 | 5 GB storage | ~1 MB |
| CloudFront | 50 GB data transfer | Minimal |
| Lambda | 1M requests/month | ~100-1000/month |
| API Gateway | 1M requests/month | ~100-1000/month |
| DynamoDB | 25 GB storage | <1 MB |
| CloudWatch | 10 custom metrics | 3 metrics |

### Estimated Monthly Cost

**Within Free Tier: $0.00**

**After Free Tier (12 months):**
- S3: ~$0.03/month
- CloudFront: ~$0.10/month
- Lambda: ~$0.00 (low traffic)
- API Gateway: ~$0.00 (low traffic)
- DynamoDB: ~$0.00 (low usage)

**Total: < $0.20/month** for a personal portfolio

## 🔧 Configuration

### Customize Variables

Edit `terraform/variables.tf`:

```hcl
variable "project_name" {
  default = "your-name-devops"  # Change this
}

variable "aws_region" {
  default = "us-east-2"  # Or your preferred region
}
```

### Update Website Content

Edit `website/index.html`:
- Update name and tagline
- Add your projects
- Update contact links
- Customize styling

## 📊 Monitoring

### CloudWatch Dashboard

Access your dashboard:
```
https://console.aws.amazon.com/cloudwatch/
→ Dashboards
→ montero-devops-portfolio-dashboard
```

Metrics displayed:
- Lambda invocations
- Lambda errors
- Lambda duration
- DynamoDB read/write capacity

### CloudWatch Logs

View Lambda logs:
```bash
aws logs tail /aws/lambda/montero-devops-visitor-counter --follow
```

### Test API Endpoint

```bash
curl https://YOUR-API-ENDPOINT/count
```

Expected response:
```json
{
  "count": 42,
  "message": "Visitor count updated successfully",
  "timestamp": "2026-02-10T12:00:00.000Z"
}
```

## 🐛 Troubleshooting

### Common Issues

#### 1. "Access Denied" on S3

**Problem:** Can't upload files to S3

**Solution:**
```bash
# Check your AWS credentials
aws sts get-caller-identity

# Ensure bucket policy is applied
cd terraform
terraform apply
```

#### 2. Visitor Counter Shows "Loading..."

**Problem:** API endpoint not updated in website

**Solution:**
- Check `deployment-info.txt` for API URL
- Update `website/index.html` with correct endpoint
- Re-upload: `./deploy.sh upload`

#### 3. CloudFront Shows 404

**Problem:** Website files not uploaded

**Solution:**
```bash
# Upload files
./deploy.sh upload

# Or manually:
aws s3 sync website/ s3://YOUR-BUCKET/ --delete
```

#### 4. Lambda Function Errors

**Problem:** DynamoDB permissions or table not found

**Solution:**
```bash
# Check Lambda logs
aws logs tail /aws/lambda/YOUR-FUNCTION-NAME --follow

# Verify DynamoDB table exists
aws dynamodb describe-table --table-name montero-devops-visitor-counter
```

#### 5. Terraform State Lock

**Problem:** "Error acquiring state lock"

**Solution:**
```bash
# Force unlock (use carefully!)
cd terraform
terraform force-unlock LOCK-ID
```

### Debug Mode

Enable detailed logging:

```bash
# Terraform
export TF_LOG=DEBUG
terraform plan

# AWS CLI
aws s3 ls --debug
```

## 🧹 Cleanup

### Destroy All Infrastructure

```bash
./deploy.sh destroy
```

Or manually:

```bash
cd terraform
terraform destroy
```

**Important:** This will:
- ❌ Delete all AWS resources
- ❌ Remove S3 bucket and contents
- ❌ Delete DynamoDB table
- ❌ Remove Lambda function
- ❌ Delete CloudFront distribution

### Partial Cleanup

To keep infrastructure but remove website:

```bash
aws s3 rm s3://YOUR-BUCKET/ --recursive
```

## 📁 Project Structure

```
aws-free-tier/
├── terraform/
│   ├── main.tf              # Main infrastructure config
│   ├── variables.tf         # Input variables
│   └── outputs.tf           # Output values
├── lambda/
│   ├── index.js             # Lambda function code
│   └── package.json         # Node.js dependencies
├── website/
│   ├── index.html           # Portfolio website
│   └── error.html           # 404 page
├── deploy.sh                # Deployment automation
└── README.md                # This file
```

## 🎯 Next Steps

### Enhancements You Can Add

1. **Custom Domain** - Route 53 + ACM certificate
2. **Email Contact Form** - SES integration
3. **Blog Section** - Additional Lambda + DynamoDB
4. **Analytics** - CloudWatch Insights
5. **CI/CD Pipeline** - GitHub Actions automation
6. **SSL Certificate** - AWS Certificate Manager
7. **WAF Rules** - AWS WAF for security

### Learning Resources

- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [CloudFront Best Practices](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/best-practices.html)

## 📝 Interview Talking Points

Use this project to demonstrate:

✅ **Infrastructure as Code** - Terraform best practices  
✅ **Serverless Architecture** - Lambda, API Gateway, DynamoDB  
✅ **Cost Optimization** - Free Tier utilization  
✅ **Security** - IAM roles, least privilege  
✅ **Monitoring** - CloudWatch dashboards and logs  
✅ **CI/CD** - Automated deployments  
✅ **Documentation** - Clear README and code comments  

## 🤝 Contributing

Feel free to customize this project for your portfolio!

## 📄 License

MIT License - Feel free to use this for your own portfolio

## 👤 Author

**QUOJO DAWSON**
- GitHub: [@QUOJO-DAWSON](https://github.com/QUOJO-DAWSON)
- AWS Account: montero
- Region: us-east-2 (Ohio)

---

**Built with ❤️ using AWS Free Tier services**

**Total Cost: $0.00** 💰
