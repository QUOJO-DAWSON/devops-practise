# File Placement Guide

This document explains where each file should be placed in your `devops-practise` repository.

## 📁 File Organization

### Root Directory Files

```
devops-practise/
├── README.md                      ← Use the provided README.md
├── CONTRIBUTING.md                ← Use the provided CONTRIBUTING.md
├── IMPLEMENTATION_GUIDE.md        ← Use the provided IMPLEMENTATION_GUIDE.md
├── LICENSE                        ← Create using implementation guide
├── CHANGELOG.md                   ← Create using implementation guide
├── .gitignore                     ← Create using quick-setup.sh or manually
├── .env.example                   ← Create using quick-setup.sh or manually
└── quick-setup.sh                 ← Use this to create directory structure
```

### CI/CD Files

```
.github/workflows/
└── ci.yml                         ← Copy provided ci.yml here

ci-cd/
├── jenkins/
│   └── Jenkinsfile                ← Copy provided Jenkinsfile here
├── github-actions/
│   └── (additional workflows)
└── gitlab-ci/
    └── .gitlab-ci.yml             ← Create if using GitLab
```

### Scripts

```
scripts/
├── setup/
│   ├── check-prerequisites.sh     ← Create using implementation guide
│   └── install-tools.sh           ← Create using implementation guide
├── deployment/
│   ├── deploy-aws.sh              ← Copy provided deploy-aws.sh here
│   ├── deploy-local.sh            ← Create based on your needs
│   └── rollback.sh                ← Create using implementation guide
├── monitoring/
│   ├── setup-monitoring.sh        ← Copy provided setup-monitoring.sh here
│   ├── setup-prometheus.sh        ← Create based on your needs
│   └── health-check.sh            ← Create using implementation guide
├── automation/
│   ├── backup.sh
│   └── cleanup.sh
└── security/
    └── scan-vulnerabilities.sh
```

### Infrastructure as Code

```
infrastructure/
├── terraform/
│   └── aws/
│       ├── main.tf                ← Copy provided main.tf here
│       ├── variables.tf           ← Copy provided variables.tf here
│       ├── outputs.tf             ← Create (already in main.tf)
│       ├── modules/
│       │   ├── vpc/
│       │   ├── eks/
│       │   └── rds/
│       └── environments/
│           ├── dev.tfvars
│           ├── staging.tfvars
│           └── production.tfvars
│
├── kubernetes/
│   ├── base/
│   │   ├── deployment.yaml        ← Copy provided deployment.yaml here
│   │   ├── service.yaml           ← Extract from deployment.yaml
│   │   ├── ingress.yaml           ← Extract from deployment.yaml
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── production/
│
└── ansible/
    ├── playbooks/
    └── roles/
```

### Docker

```
docker/
├── Dockerfile                     ← Copy provided Dockerfile here
├── docker-compose.yml             ← Create using implementation guide
├── docker-compose.test.yml        ← Create for testing
└── .dockerignore
```

### Documentation

```
docs/
├── architecture.md                ← Create using implementation guide
├── best-practices.md              ← Create using implementation guide
└── troubleshooting.md
```

### Monitoring

```
monitoring/
├── prometheus/
│   ├── prometheus.yml
│   └── alert-rules.yml
├── grafana/
│   ├── dashboards/
│   └── datasources.yml
└── elk/
    └── logstash.conf
```

## 🚀 Quick Setup Process

### Option 1: Using the Quick Setup Script (Recommended)

1. **Copy `quick-setup.sh` to your repository root**
   ```bash
   cp /path/to/downloaded/quick-setup.sh /path/to/devops-practise/
   cd /path/to/devops-practise
   ```

2. **Run the setup script**
   ```bash
   chmod +x quick-setup.sh
   ./quick-setup.sh
   ```

3. **Copy files to their designated locations**
   ```bash
   # Root files
   cp /path/to/downloaded/README.md ./
   cp /path/to/downloaded/CONTRIBUTING.md ./
   cp /path/to/downloaded/IMPLEMENTATION_GUIDE.md ./
   
   # CI/CD
   mkdir -p .github/workflows
   cp /path/to/downloaded/ci.yml .github/workflows/
   
   mkdir -p ci-cd/jenkins
   cp /path/to/downloaded/Jenkinsfile ci-cd/jenkins/
   
   # Scripts
   mkdir -p scripts/deployment
   cp /path/to/downloaded/deploy-aws.sh scripts/deployment/
   
   mkdir -p scripts/monitoring
   cp /path/to/downloaded/setup-monitoring.sh scripts/monitoring/
   
   # Infrastructure
   mkdir -p infrastructure/terraform/aws
   cp /path/to/downloaded/main.tf infrastructure/terraform/aws/
   cp /path/to/downloaded/variables.tf infrastructure/terraform/aws/
   
   mkdir -p infrastructure/kubernetes/base
   cp /path/to/downloaded/deployment.yaml infrastructure/kubernetes/base/
   
   # Docker
   mkdir -p docker
   cp /path/to/downloaded/Dockerfile docker/
   ```

4. **Make scripts executable**
   ```bash
   find scripts -name "*.sh" -type f -exec chmod +x {} \;
   ```

### Option 2: Manual Setup

Follow the step-by-step instructions in `IMPLEMENTATION_GUIDE.md`

## 📝 Next Steps After File Placement

1. **Review and Customize**
   - Update README.md with your actual information
   - Modify scripts to match your environment
   - Update Terraform variables for your AWS account
   - Customize Kubernetes manifests for your application

2. **Test Configurations**
   ```bash
   # Test Terraform
   cd infrastructure/terraform/aws
   terraform validate
   
   # Test Kubernetes manifests
   kubectl apply --dry-run=client -f infrastructure/kubernetes/base/
   
   # Test scripts
   shellcheck scripts/**/*.sh
   ```

3. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: add comprehensive DevOps automation and documentation"
   git push origin main
   ```

## 🎯 Priority Files to Focus On

If you're short on time, focus on these files first:

1. **README.md** - Most important for first impressions
2. **CI/CD workflows** - Shows automation skills
3. **deploy-aws.sh** - Demonstrates scripting ability
4. **main.tf** - Shows IaC expertise
5. **deployment.yaml** - Kubernetes knowledge

## 🔍 File Checklist

Use this checklist to track your progress:

### Core Documentation
- [ ] README.md copied and customized
- [ ] CONTRIBUTING.md in place
- [ ] IMPLEMENTATION_GUIDE.md available
- [ ] LICENSE file created
- [ ] .gitignore configured

### CI/CD
- [ ] GitHub Actions workflow configured (.github/workflows/ci.yml)
- [ ] Jenkinsfile in place (ci-cd/jenkins/Jenkinsfile)
- [ ] Secrets configured in GitHub

### Scripts
- [ ] Deployment scripts added and executable
- [ ] Monitoring scripts configured
- [ ] All scripts tested

### Infrastructure
- [ ] Terraform files in place and validated
- [ ] Kubernetes manifests configured
- [ ] Docker files created

### Additional
- [ ] Documentation completed
- [ ] Examples added
- [ ] Tests created

## 💡 Tips

1. **Don't Rush**: Take time to understand each file
2. **Customize**: Make it reflect your actual experience
3. **Test**: Ensure everything works before committing
4. **Document**: Add comments to explain complex parts
5. **Be Consistent**: Use consistent naming and formatting

## 🆘 Troubleshooting

### Scripts Not Executable
```bash
chmod +x scripts/**/*.sh
```

### Terraform Validation Fails
```bash
cd infrastructure/terraform/aws
terraform fmt
terraform init -backend=false
terraform validate
```

### Kubernetes Manifest Errors
```bash
kubectl apply --dry-run=client -f <manifest-file>
```

## 📞 Support

Refer to `IMPLEMENTATION_GUIDE.md` for detailed instructions and troubleshooting.

---

**Good luck with your repository optimization!** 🚀
