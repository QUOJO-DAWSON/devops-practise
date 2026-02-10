# 🚀 DevOps Practice Repository

![DevOps](https://img.shields.io/badge/DevOps-Practice-blue?style=for-the-badge)
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)
![Jenkins](https://img.shields.io/badge/jenkins-%232C5263.svg?style=for-the-badge&logo=jenkins&logoColor=white)

> **A comprehensive collection of production-ready DevOps automation scripts, CI/CD pipelines, and infrastructure-as-code templates for cloud-native applications.**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Usage Examples](#usage-examples)
- [CI/CD Pipelines](#cicd-pipelines)
- [Infrastructure as Code](#infrastructure-as-code)
- [Monitoring & Logging](#monitoring--logging)
- [Security Best Practices](#security-best-practices)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## 🎯 Overview

This repository demonstrates real-world DevOps practices and automation techniques used in production environments. It includes:

- **Automated deployment scripts** for multiple cloud providers
- **CI/CD pipeline configurations** for Jenkins, GitHub Actions, and GitLab
- **Infrastructure as Code** templates using Terraform and Ansible
- **Container orchestration** with Docker and Kubernetes
- **Monitoring and alerting** setup with Prometheus and Grafana
- **Security scanning** and compliance automation

### 💼 Business Value

- **Reduces deployment time** by 70% through automation
- **Minimizes human error** with standardized processes
- **Ensures consistency** across development, staging, and production
- **Improves security** with automated scanning and compliance checks
- **Enables rapid scaling** with infrastructure as code

---

## ✨ Features

### 🔄 CI/CD Automation
- ✅ Multi-stage pipeline configurations
- ✅ Automated testing and code quality checks
- ✅ Container image building and scanning
- ✅ Blue-green and canary deployment strategies
- ✅ Automated rollback mechanisms

### ☁️ Cloud Infrastructure
- ✅ AWS resource provisioning with Terraform
- ✅ Azure infrastructure automation
- ✅ Multi-cloud deployment strategies
- ✅ Auto-scaling configurations
- ✅ Cost optimization scripts

### 🐳 Containerization
- ✅ Optimized Dockerfiles with multi-stage builds
- ✅ Docker Compose for local development
- ✅ Kubernetes manifests and Helm charts
- ✅ Service mesh integration (Istio)
- ✅ Container security scanning

### 📊 Monitoring & Observability
- ✅ Prometheus metric collection
- ✅ Grafana dashboard configurations
- ✅ ELK stack setup for log aggregation
- ✅ Custom alerting rules
- ✅ Distributed tracing with Jaeger

### 🔒 Security
- ✅ Secrets management with Vault
- ✅ SAST/DAST integration
- ✅ Container vulnerability scanning
- ✅ Network policies and firewall rules
- ✅ Compliance automation (CIS benchmarks)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Developer                            │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│                    Version Control (GitHub)                  │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│              CI/CD Pipeline (Jenkins/GitHub Actions)         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │   Build  │→ │   Test   │→ │  Scan    │→ │  Deploy  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│        Container Registry (ECR/Docker Hub/ACR)              │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│           Kubernetes Cluster (EKS/AKS/GKE)                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │   Dev    │  │  Staging │  │   Prod   │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│              Monitoring & Logging                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │Prometheus│  │ Grafana  │  │   ELK    │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Prerequisites

### Required Tools
- **Docker** >= 20.10
- **Kubernetes** >= 1.24 (kubectl, minikube for local)
- **Terraform** >= 1.5.0
- **Ansible** >= 2.14
- **AWS CLI** >= 2.x (for AWS deployments)
- **Azure CLI** >= 2.x (for Azure deployments)
- **Helm** >= 3.x
- **Git** >= 2.x

### Recommended Knowledge
- Linux/Unix command line
- Shell scripting (Bash)
- Container concepts
- Cloud platform basics
- Infrastructure as Code principles

---

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/QUOJO-DAWSON/devops-practise.git
cd devops-practise
```

### 2. Set Up Environment Variables
```bash
cp .env.example .env
# Edit .env with your configurations
nano .env
```

### 3. Run Pre-checks
```bash
# Check all required tools are installed
./scripts/setup/check-prerequisites.sh

# Set up local development environment
./scripts/setup/setup-local-env.sh
```

### 4. Deploy a Sample Application
```bash
# Deploy to local Kubernetes cluster
./scripts/deployment/deploy-local.sh

# Or deploy to AWS
./scripts/deployment/deploy-aws.sh --environment dev
```

### 5. Access Monitoring Dashboards
```bash
# Port-forward Grafana
kubectl port-forward svc/grafana 3000:3000 -n monitoring

# Access at http://localhost:3000 (admin/admin)
```

---

## 📁 Project Structure

```
devops-practise/
├── README.md                          # This file
├── CONTRIBUTING.md                    # Contribution guidelines
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore rules
├── .env.example                       # Environment variables template
│
├── docs/                              # Documentation
│   ├── architecture.md                # System architecture details
│   ├── best-practices.md              # DevOps best practices
│   ├── troubleshooting.md             # Common issues and solutions
│   └── api-reference.md               # Script API documentation
│
├── scripts/                           # Automation scripts
│   ├── setup/                         # Initial setup scripts
│   │   ├── check-prerequisites.sh     # Check required tools
│   │   ├── setup-local-env.sh         # Local environment setup
│   │   └── install-tools.sh           # Install DevOps tools
│   │
│   ├── deployment/                    # Deployment automation
│   │   ├── deploy-local.sh            # Local deployment
│   │   ├── deploy-aws.sh              # AWS deployment
│   │   ├── deploy-azure.sh            # Azure deployment
│   │   ├── rollback.sh                # Automated rollback
│   │   └── blue-green-deploy.sh       # Blue-green deployment
│   │
│   ├── monitoring/                    # Monitoring setup
│   │   ├── setup-prometheus.sh        # Prometheus installation
│   │   ├── setup-grafana.sh           # Grafana setup
│   │   ├── configure-alerts.sh        # Alert configuration
│   │   └── health-check.sh            # Health monitoring
│   │
│   ├── automation/                    # General automation
│   │   ├── backup.sh                  # Backup automation
│   │   ├── cleanup.sh                 # Resource cleanup
│   │   ├── scale.sh                   # Auto-scaling
│   │   └── cost-optimizer.sh          # Cost optimization
│   │
│   └── security/                      # Security scripts
│       ├── scan-vulnerabilities.sh    # Vulnerability scanning
│       ├── rotate-secrets.sh          # Secret rotation
│       ├── audit-compliance.sh        # Compliance checking
│       └── harden-system.sh           # System hardening
│
├── ci-cd/                             # CI/CD configurations
│   ├── jenkins/                       # Jenkins pipelines
│   │   ├── Jenkinsfile                # Main pipeline
│   │   ├── Jenkinsfile.build          # Build stage
│   │   └── Jenkinsfile.deploy         # Deploy stage
│   │
│   ├── github-actions/                # GitHub Actions workflows
│   │   ├── ci.yml                     # Continuous Integration
│   │   ├── cd.yml                     # Continuous Deployment
│   │   ├── security-scan.yml          # Security scanning
│   │   └── terraform-plan.yml         # Infrastructure preview
│   │
│   └── gitlab-ci/                     # GitLab CI/CD
│       └── .gitlab-ci.yml             # GitLab pipeline
│
├── infrastructure/                    # Infrastructure as Code
│   ├── terraform/                     # Terraform configurations
│   │   ├── aws/                       # AWS resources
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── modules/
│   │   │       ├── vpc/
│   │   │       ├── eks/
│   │   │       └── rds/
│   │   │
│   │   └── azure/                     # Azure resources
│   │       ├── main.tf
│   │       └── modules/
│   │
│   ├── ansible/                       # Ansible playbooks
│   │   ├── playbooks/
│   │   │   ├── install-docker.yml
│   │   │   ├── setup-k8s.yml
│   │   │   └── configure-monitoring.yml
│   │   │
│   │   └── roles/                     # Ansible roles
│   │       ├── common/
│   │       ├── docker/
│   │       └── kubernetes/
│   │
│   └── kubernetes/                    # Kubernetes manifests
│       ├── base/                      # Base configurations
│       │   ├── namespace.yaml
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   └── ingress.yaml
│       │
│       ├── overlays/                  # Environment-specific
│       │   ├── dev/
│       │   ├── staging/
│       │   └── production/
│       │
│       └── helm/                      # Helm charts
│           └── app-chart/
│               ├── Chart.yaml
│               ├── values.yaml
│               └── templates/
│
├── monitoring/                        # Monitoring configurations
│   ├── prometheus/
│   │   ├── prometheus.yml
│   │   ├── alert-rules.yml
│   │   └── recording-rules.yml
│   │
│   ├── grafana/
│   │   ├── dashboards/
│   │   │   ├── application.json
│   │   │   ├── infrastructure.json
│   │   │   └── kubernetes.json
│   │   └── datasources.yml
│   │
│   └── elk/
│       ├── logstash.conf
│       ├── elasticsearch.yml
│       └── kibana.yml
│
├── docker/                            # Docker configurations
│   ├── Dockerfile                     # Main application
│   ├── Dockerfile.nginx               # Nginx
│   ├── docker-compose.yml             # Local stack
│   └── docker-compose.prod.yml        # Production stack
│
├── tests/                             # Test scripts
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
└── examples/                          # Usage examples
    ├── simple-deployment/
    ├── microservices/
    └── serverless/
```

---

## 💡 Usage Examples

### Example 1: Deploy Application to Kubernetes

```bash
# Deploy to development environment
./scripts/deployment/deploy-local.sh --namespace dev --app myapp

# Deploy to production with health checks
./scripts/deployment/deploy-aws.sh \
  --environment production \
  --app myapp \
  --health-check true \
  --replicas 3
```

### Example 2: Set Up Monitoring Stack

```bash
# Install Prometheus and Grafana
./scripts/monitoring/setup-prometheus.sh
./scripts/monitoring/setup-grafana.sh

# Configure custom alerts
./scripts/monitoring/configure-alerts.sh \
  --alert-name high-cpu \
  --threshold 80 \
  --slack-webhook $SLACK_WEBHOOK_URL
```

### Example 3: Infrastructure Provisioning

```bash
# Initialize Terraform
cd infrastructure/terraform/aws
terraform init

# Plan infrastructure changes
terraform plan -var-file=environments/dev.tfvars

# Apply changes
terraform apply -var-file=environments/dev.tfvars -auto-approve
```

### Example 4: Automated Backup

```bash
# Backup databases and configurations
./scripts/automation/backup.sh \
  --type full \
  --destination s3://my-backups/$(date +%Y%m%d) \
  --retention-days 30
```

### Example 5: Security Scanning

```bash
# Scan Docker images for vulnerabilities
./scripts/security/scan-vulnerabilities.sh \
  --image myapp:latest \
  --severity HIGH,CRITICAL

# Run compliance audit
./scripts/security/audit-compliance.sh \
  --framework CIS \
  --output-format json
```

---

## 🔄 CI/CD Pipelines

### GitHub Actions Workflow

The repository includes automated CI/CD workflows that:

1. **Build & Test**: Compile code, run unit tests, and generate coverage reports
2. **Security Scan**: Check for vulnerabilities in dependencies and containers
3. **Infrastructure Validation**: Validate Terraform and Kubernetes manifests
4. **Deploy**: Automated deployment to development/staging/production
5. **Monitoring**: Integration with monitoring tools for deployment verification

**Workflow Trigger**: Push to `main`, `develop`, or pull requests

### Jenkins Pipeline

Multi-stage Jenkins pipeline with:
- Parallel test execution
- Docker image building with layer caching
- Quality gates with SonarQube
- Approval gates for production
- Automated rollback on failure

---

## 🏗️ Infrastructure as Code

### Terraform Modules

**AWS Infrastructure**:
- VPC with public/private subnets
- EKS cluster with managed node groups
- RDS database with automated backups
- Application Load Balancer
- S3 buckets with versioning and encryption
- CloudWatch logging and monitoring

**Azure Infrastructure**:
- Virtual Network and subnets
- AKS cluster
- Azure Database
- Application Gateway
- Storage accounts
- Azure Monitor

### Ansible Automation

**Server Configuration**:
- Docker installation and configuration
- Kubernetes cluster setup
- Security hardening (firewall, SSH, fail2ban)
- Application deployment
- Monitoring agent installation

---

## 📊 Monitoring & Logging

### Prometheus Metrics

Custom metrics collected:
- Application response time
- Request rate and error rate
- Resource utilization (CPU, memory, disk)
- Database connection pool status
- Queue depth and processing time

### Grafana Dashboards

Pre-configured dashboards for:
- **Application Performance**: Request rates, latencies, error rates
- **Infrastructure Health**: Node status, pod health, resource usage
- **Database Monitoring**: Query performance, connection pools, locks
- **Business Metrics**: User activity, transaction volume

### Log Aggregation

ELK Stack configuration for:
- Centralized log collection from all services
- Real-time log analysis
- Custom log patterns and parsing
- Alert triggers based on log patterns
- Long-term log retention with S3 archival

---

## 🔒 Security Best Practices

### Implemented Security Measures

✅ **Secrets Management**: HashiCorp Vault integration  
✅ **Image Scanning**: Trivy for container vulnerability scanning  
✅ **Network Policies**: Kubernetes network policies for pod isolation  
✅ **RBAC**: Role-based access control for Kubernetes and cloud resources  
✅ **Encryption**: At-rest and in-transit encryption for all sensitive data  
✅ **Security Scanning**: Automated SAST/DAST in CI/CD pipeline  
✅ **Compliance**: CIS benchmark automation and reporting  
✅ **Audit Logging**: Comprehensive audit trails for all operations

### Security Checklist

Before deploying to production:

- [ ] All secrets stored in vault/secrets manager
- [ ] Container images scanned and approved
- [ ] Network policies configured
- [ ] RBAC policies reviewed and applied
- [ ] Encryption enabled for data at rest
- [ ] TLS/SSL configured for all endpoints
- [ ] Backup and disaster recovery tested
- [ ] Security monitoring and alerting enabled

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact

**QUOJO DAWSON**

- GitHub: [@QUOJO-DAWSON](https://github.com/QUOJO-DAWSON)
- LinkedIn: [Connect with me](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com

---

## 🙏 Acknowledgments

- Thanks to the DevOps community for best practices and tools
- Inspired by real-world production environments
- Built with enterprise-grade reliability in mind

---

## ⭐ Star History

If you find this repository helpful, please consider giving it a star! ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=QUOJO-DAWSON/devops-practise&type=Date)](https://star-history.com/#QUOJO-DAWSON/devops-practise&Date)

---

**Made with ❤️ by QUOJO DAWSON | DevOps Engineer**
