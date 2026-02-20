# Disaster Recovery Plan

## Executive Summary

This document outlines disaster recovery procedures for the AWS serverless portfolio infrastructure. The architecture is designed for resilience with automated backups, point-in-time recovery, and infrastructure-as-code for rapid reconstruction.

## Recovery Objectives

### RTO (Recovery Time Objective)
**Target: 1 hour**

Maximum acceptable time to restore service after a failure:
- Infrastructure rebuild: 45 minutes
- Data restoration: 15 minutes
- Validation and testing: 10 minutes

### RPO (Recovery Point Objective)
**Target: 24 hours**

Maximum acceptable data loss:
- DynamoDB: Point-in-time recovery (any point in last 35 days)
- S3: Versioning enabled (30-day retention)
- Infrastructure: Version controlled in Git (no data loss)

## Backup Strategy

### DynamoDB Backups
**Automated Backups:**
- Point-in-time recovery enabled
- Continuous backups (35-day retention)
- Can restore to any second in the last 35 days
- No performance impact
- Stored in same region

**Verification Schedule:**
- Monthly: Test restore to temporary table
- Quarterly: Full recovery drill

### S3 Backups
**Versioning:**
- All file versions retained
- 30-day lifecycle policy for old versions
- Recoverable from accidental deletion
- Versioning cost: ~\.01/month

**Cross-Region Replication (Future):**
- Planned: us-west-2 replica bucket
- Asynchronous replication
- Regional failure protection

### Infrastructure as Code
**Terraform State:**
- Version controlled in GitHub
- Encrypted at rest
- Backed up with Git
- Can rebuild entire infrastructure

**Code Repository:**
- GitHub: github.com/QUOJO-DAWSON/devops-practise
- All commits tagged
- Protected main branch
- Complete history

## Disaster Scenarios & Response

### Scenario 1: Lambda Function Failure

**Symptoms:**
- API returns 5xx errors
- CloudWatch alarm triggered
- Visitor counter not incrementing

**Root Cause Analysis:**
\\\ash
# Check CloudWatch logs
aws logs tail /aws/lambda/montero-devops-visitor-counter --follow

# Check Lambda metrics
aws cloudwatch get-metric-statistics \\
  --namespace AWS/Lambda \\
  --metric-name Errors \\
  --dimensions Name=FunctionName,Value=montero-devops-visitor-counter \\
  --start-time 2026-02-20T00:00:00Z \\
  --end-time 2026-02-20T23:59:59Z \\
  --period 3600 \\
  --statistics Sum
\\\

**Recovery Steps:**
1. Identify the error in CloudWatch Logs
2. Fix code issue locally
3. Test locally if possible
4. Deploy fix:
\\\ash
cd aws-free-tier/terraform
terraform apply -target=aws_lambda_function.visitor_counter
\\\
5. Verify functionality
6. Monitor for 30 minutes

**Estimated Recovery Time:** 15-30 minutes  
**Data Loss:** None

---

### Scenario 2: DynamoDB Data Corruption

**Symptoms:**
- Incorrect visitor count
- Missing data
- Unexpected values

**Root Cause Analysis:**
\\\ash
# Query current state
aws dynamodb scan \\
  --table-name montero-devops-visitor-counter \\
  --region us-east-2

# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \\
  --namespace AWS/DynamoDB \\
  --metric-name UserErrors \\
  --dimensions Name=TableName,Value=montero-devops-visitor-counter \\
  --start-time 2026-02-20T00:00:00Z \\
  --end-time 2026-02-20T23:59:59Z \\
  --period 300 \\
  --statistics Sum
\\\

**Recovery Steps:**
1. Identify last known good timestamp
2. Create restore point:
\\\ash
# Restore to specific time
aws dynamodb restore-table-to-point-in-time \\
  --source-table-name montero-devops-visitor-counter \\
  --target-table-name montero-devops-visitor-counter-restored \\
  --restore-date-time 2026-02-19T12:00:00 \\
  --region us-east-2
\\\
3. Wait for restore completion (~10-20 minutes)
4. Verify restored data
5. Update Terraform to point to new table (if needed)
6. Delete corrupted table

**Estimated Recovery Time:** 30-45 minutes  
**Data Loss:** Maximum 24 hours (to last restore point)

---

### Scenario 3: S3 Bucket Deletion

**Symptoms:**
- Website unavailable
- 403/404 errors from CloudFront
- S3 bucket missing

**Root Cause Analysis:**
\\\ash
# Check bucket status
aws s3 ls s3://montero-devops-portfolio-271758791081

# Check CloudTrail for deletion event
aws cloudtrail lookup-events \\
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=montero-devops-portfolio-271758791081 \\
  --max-results 50
\\\

**Recovery Steps:**
1. If versioning was enabled, check for deleted marker
2. Recreate bucket with Terraform:
\\\ash
cd aws-free-tier/terraform
terraform apply -target=aws_s3_bucket.portfolio_website
\\\
3. Re-upload website files:
\\\ash
cd ../website
aws s3 sync . s3://montero-devops-portfolio-271758791081/ --delete
\\\
4. Invalidate CloudFront cache:
\\\ash
aws cloudfront create-invalidation \\
  --distribution-id EEY6IGYA5M556 \\
  --paths "/*"
\\\
5. Verify website accessibility

**Estimated Recovery Time:** 15-20 minutes  
**Data Loss:** None (files in Git)

---

### Scenario 4: Complete Infrastructure Loss

**Symptoms:**
- All AWS resources deleted
- Complete service outage
- Terraform state shows no resources

**Root Cause Analysis:**
- Accidental \	erraform destroy\
- AWS account compromise
- Region-wide failure

**Recovery Steps:**

**Step 1: Clone Repository**
\\\ash
git clone https://github.com/QUOJO-DAWSON/devops-practise.git
cd devops-practise/aws-free-tier
\\\

**Step 2: Install Dependencies**
\\\ash
cd lambda
npm install
cd ../terraform
\\\

**Step 3: Initialize Terraform**
\\\ash
terraform init
\\\

**Step 4: Deploy Infrastructure**
\\\ash
terraform plan
terraform apply
# Type: yes
\\\

**Step 5: Upload Website**
\\\ash
cd ../website
aws s3 sync . s3://[new-bucket-name]/ --delete
\\\

**Step 6: Get New Endpoints**
\\\ash
cd ../terraform
terraform output
\\\

**Step 7: Update Website with New API Endpoint**
\\\ash
# Edit website/index.html with new API Gateway URL
# Re-upload to S3
aws s3 sync ../website/ s3://[bucket-name]/
\\\

**Step 8: Invalidate CloudFront**
\\\ash
aws cloudfront create-invalidation \\
  --distribution-id [new-distribution-id] \\
  --paths "/*"
\\\

**Step 9: Restore DynamoDB Data (if backup exists)**
\\\ash
# If cross-region backup exists
aws dynamodb restore-table-from-backup \\
  --target-table-name montero-devops-visitor-counter \\
  --backup-arn [backup-arn]
\\\

**Estimated Recovery Time:** 45-60 minutes  
**Data Loss:** Visitor count (unless cross-region backup exists)

---

### Scenario 5: CloudFront Distribution Misconfiguration

**Symptoms:**
- Website loads slowly
- SSL/TLS errors
- Cache misses increase

**Recovery Steps:**
1. Identify misconfiguration in Terraform state
2. Revert to last known good configuration:
\\\ash
git log --oneline terraform/main.tf
git checkout [commit-hash] -- terraform/main.tf
terraform apply
\\\
3. Monitor CloudFront metrics
4. Invalidate cache if needed

**Estimated Recovery Time:** 20-30 minutes  
**Data Loss:** None

---

### Scenario 6: API Gateway Failure

**Symptoms:**
- API endpoint returns errors
- Lambda not being invoked
- Integration timeout

**Recovery Steps:**
1. Check API Gateway logs
2. Verify Lambda function health
3. Recreate API Gateway:
\\\ash
cd terraform
terraform taint aws_apigatewayv2_api.visitor_counter
terraform apply
\\\
4. Update website with new endpoint
5. Test thoroughly

**Estimated Recovery Time:** 15-25 minutes  
**Data Loss:** None

---

## Testing & Validation

### Monthly Tests
- [ ] Verify DynamoDB backups are accessible
- [ ] Test S3 file versioning recovery
- [ ] Confirm CloudWatch alarms are functional
- [ ] Review Terraform state integrity

### Quarterly Drills
- [ ] Full infrastructure rebuild from scratch
- [ ] DynamoDB point-in-time recovery
- [ ] Failover to backup region (when available)
- [ ] Team communication and escalation

### Annual Review
- [ ] Update recovery procedures
- [ ] Review RTO/RPO targets
- [ ] Test restore from cold backup
- [ ] Document lessons learned

## Contact Information

### Primary On-Call
- **Name:** George Dawson-Kesson
- **Email:** dawsonkessongp@gmail.com
- **Phone:** (513) 266-4741

### AWS Support
- **Plan:** Free Tier (7-day response)
- **Upgrade for emergencies:** Business Support (\/month minimum)
- **Support Center:** https://console.aws.amazon.com/support/

### Escalation Path
1. Primary on-call (immediate)
2. AWS Support ticket (< 24 hours)
3. Community forums (AWS, Stack Overflow)

## Runbook Locations

### Documentation
- **GitHub:** https://github.com/QUOJO-DAWSON/devops-practise
- **Local:** C:\Users\dawso\devops-practise\

### Key Files
- \DISASTER-RECOVERY.md\ - This document
- \ARCHITECTURE.md\ - System architecture
- \DEVELOPMENT.md\ - Development methodology
- \ws-free-tier/README.md\ - Deployment guide
- \ws-free-tier/terraform/\ - Infrastructure code

## Preventive Measures

### Implemented
- [x] S3 bucket versioning
- [x] DynamoDB point-in-time recovery
- [x] Infrastructure as Code (Terraform)
- [x] CloudWatch alarms and monitoring
- [x] S3 encryption at rest
- [x] IAM least privilege access
- [x] Version control (Git/GitHub)

### Planned
- [ ] Cross-region replication (S3, DynamoDB)
- [ ] AWS Backup service integration
- [ ] Automated testing in CI/CD
- [ ] Blue-green deployment strategy
- [ ] Multi-region failover
- [ ] Enhanced monitoring and alerting
- [ ] Automated backup validation

## Post-Incident Review

### Required Documentation
After any incident:
1. **Timeline** of events
2. **Root cause** analysis
3. **Recovery steps** taken
4. **Lessons learned**
5. **Preventive actions** to implement

### Template
\\\markdown
## Incident Report: [Date] - [Title]

**Severity:** [Critical/High/Medium/Low]  
**Duration:** [Start time] - [End time]  
**Impact:** [Description]  

### Timeline
- HH:MM - Event description
- HH:MM - Action taken

### Root Cause
[Detailed analysis]

### Resolution
[Steps taken to resolve]

### Prevention
[Actions to prevent recurrence]
\\\

## Compliance & Audit

### Backup Verification
- Automated monthly backup tests
- Documented recovery procedures
- Regular drill exercises
- Backup retention compliance

### Change Management
- All changes via Terraform
- Git commits for audit trail
- Peer review for critical changes
- Rollback procedures documented

## References

### AWS Documentation
- [DynamoDB Backup & Restore](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/BackupRestore.html)
- [S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)

### Internal Documentation
- Architecture diagram: ARCHITECTURE.md
- Deployment guide: aws-free-tier/README.md
- Terraform code: aws-free-tier/terraform/

---

**Document Version:** 1.0  
**Last Updated:** February 20, 2026  
**Next Review:** May 20, 2026  
**Owner:** George Dawson-Kesson
