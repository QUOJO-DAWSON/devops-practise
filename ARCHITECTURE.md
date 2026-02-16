# Architecture Overview

## System Architecture

\\\

                         End Users                            

                           
                            HTTPS
                           
                  
                    CloudFront CDN 
                    Global Edge    
                  
                           
        
                                            
                                            
                
    S3 Bucket         API          CloudWatch
    Website         Gateway        Monitoring
                
                         
                         
                  
                     Lambda    
                    Function   
                  
                         
                         
                  
                    DynamoDB   
                     Table     
                  
\\\

## Components

### Frontend Layer
**CloudFront CDN**
- Global edge locations for low-latency delivery
- HTTPS enforcement with SSL/TLS certificates
- Cache optimization for static assets
- Custom error pages (403, 404)
- Origin access identity for S3 security

**S3 Static Website Hosting**
- HTML, CSS, JavaScript files
- Versioning enabled for rollback capability
- Server-side encryption (AES-256)
- Lifecycle policies for cost optimization

### API Layer
**API Gateway (HTTP API)**
- RESTful endpoint: /count
- CORS enabled for cross-origin requests
- Automatic request/response validation
- CloudWatch integration for monitoring
- Low-latency HTTP API (not REST API)

**Lambda Function**
- Runtime: Node.js 18.x
- Memory: 256 MB
- Timeout: 15 seconds
- Execution role with least-privilege IAM permissions
- Environment variables for configuration
- Asynchronous DynamoDB operations

### Data Layer
**DynamoDB Table**
- On-demand billing (pay-per-request)
- Point-in-time recovery enabled
- Single-table design for visitor counter
- Partition key: counter_id
- Automatic scaling with on-demand capacity

### Operational Layer
**CloudWatch**
- Custom dashboard with Lambda and DynamoDB metrics
- Enhanced alarms for errors, latency, throttling
- Log aggregation from Lambda functions
- Metric filters for custom insights
- Automated alerting on threshold breaches

**IAM Roles & Policies**
- Lambda execution role with DynamoDB access
- S3 bucket policies for CloudFront access
- Least privilege principle throughout
- No hardcoded credentials

## Data Flow

### Website Request Flow
1. User navigates to CloudFront URL
2. CloudFront checks edge cache
3. If miss, retrieves from S3 origin
4. Serves HTML/CSS/JS to user
5. Browser renders website

### API Request Flow
1. JavaScript makes GET request to API Gateway
2. API Gateway invokes Lambda function
3. Lambda reads current count from DynamoDB
4. Lambda increments count
5. Lambda writes updated count to DynamoDB
6. Lambda returns JSON response
7. JavaScript updates page with new count

### Monitoring Flow
1. All services emit metrics to CloudWatch
2. Custom dashboard displays real-time metrics
3. Alarms evaluate thresholds every 5 minutes
4. Lambda logs captured for debugging
5. DynamoDB metrics track read/write usage

## Security Architecture

### Network Security
- All traffic over HTTPS/TLS 1.2+
- CloudFront signed URLs (configurable)
- API Gateway rate limiting
- No public S3 bucket access
- Origin Access Identity for CloudFront  S3

### Identity & Access
- IAM roles (no access keys)
- Least privilege permissions
- Service-to-service authentication
- No secrets in code or environment variables
- Automated credential rotation (AWS managed)

### Data Security
- S3 server-side encryption at rest
- DynamoDB encryption at rest (AWS managed)
- TLS encryption in transit
- CloudWatch Logs encryption
- No PII stored

## Scalability & Performance

### Auto-Scaling
- **Lambda**: Automatic (up to 1000 concurrent executions)
- **DynamoDB**: On-demand capacity (scales automatically)
- **CloudFront**: Global edge network (automatic)
- **API Gateway**: Handles millions of requests

### Performance Optimizations
- CloudFront edge caching (reduces origin load)
- Lambda memory optimization (256 MB)
- DynamoDB single-digit millisecond latency
- Asynchronous operations where possible
- Minimal cold start impact (simple function)

### High Availability
- Multi-AZ deployment (automatic with managed services)
- CloudFront 100% uptime SLA
- Lambda automatic retries
- DynamoDB 99.99% availability SLA
- No single points of failure

## Cost Optimization

### Free Tier Eligible
- S3: 5 GB storage (using <1 MB)
- CloudFront: 50 GB data transfer
- Lambda: 1M requests + 400,000 GB-seconds
- API Gateway: 1M requests
- DynamoDB: 25 GB storage + 25 WCU/RCU
- CloudWatch: 10 custom metrics

### Cost-Saving Strategies
- On-demand DynamoDB (no idle capacity charges)
- Minimal Lambda memory allocation
- CloudFront cache optimization
- S3 lifecycle policies
- No NAT Gateway or VPC costs
- **Current cost: \.00/month**

### Post-Free-Tier Estimates
- S3: ~\.023/month
- CloudFront: ~\.085/month (1 GB transfer)
- Lambda: ~\.02/month (10K requests)
- API Gateway: ~\.01/month (10K requests)
- DynamoDB: ~\.25/month (minimal usage)
- **Estimated: <\.40/month after Free Tier**

## Disaster Recovery

### Backup Strategy
- DynamoDB: Point-in-time recovery (35 days)
- S3: Versioning enabled (30-day retention)
- Terraform state: Version controlled in Git
- Infrastructure: Fully reproducible from code

### Recovery Objectives
- **RTO** (Recovery Time Objective): 1 hour
- **RPO** (Recovery Point Objective): 24 hours
- Full infrastructure rebuild: 45 minutes
- Data restoration: 30 minutes

### Failure Scenarios
- **Lambda failure**: Automatic retries + rollback
- **DynamoDB corruption**: Point-in-time restore
- **Complete loss**: Terraform rebuild + data restore
- **Region outage**: Cross-region replication (future)

## Deployment Process

### Infrastructure as Code
1. Developer updates Terraform configuration
2. \	erraform plan\ validates changes
3. Review plan for correctness
4. \	erraform apply\ deploys infrastructure
5. Changes tracked in version control

### Application Deployment
1. Update Lambda function code
2. Package dependencies (\
pm install\)
3. Terraform detects code changes
4. Automatic function deployment
5. Zero downtime (Lambda versioning)

### Website Deployment
1. Update HTML/CSS/JavaScript
2. Sync to S3 bucket
3. Invalidate CloudFront cache
4. New content available globally in ~2 minutes

## Monitoring & Observability

### Key Metrics
- Lambda invocations per minute
- Lambda error rate
- Lambda duration (p50, p95, p99)
- API Gateway 4xx/5xx errors
- API Gateway latency
- DynamoDB read/write capacity
- CloudFront cache hit ratio

### Alerting Thresholds
- Lambda errors > 5 in 5 minutes
- API latency > 1000ms (2 consecutive periods)
- Lambda throttles > 10 in 5 minutes
- DynamoDB throttles (any)

### Logging
- Lambda execution logs (CloudWatch Logs)
- API Gateway access logs
- CloudFront access logs (optional)
- Structured JSON logging
- 30-day retention period

## Technology Stack

### Infrastructure
- **IaC**: Terraform 1.14.4
- **Cloud**: AWS (us-east-2 region)
- **State Management**: Terraform state file

### Frontend
- **Hosting**: Amazon S3
- **CDN**: Amazon CloudFront
- **Languages**: HTML5, CSS3, JavaScript (ES6+)

### Backend
- **Compute**: AWS Lambda (Node.js 18.x)
- **API**: Amazon API Gateway (HTTP API)
- **Database**: Amazon DynamoDB
- **Dependencies**: AWS SDK v3

### DevOps
- **CI/CD**: GitHub Actions
- **Version Control**: Git/GitHub
- **Monitoring**: Amazon CloudWatch
- **Documentation**: Markdown

## Future Enhancements

### Planned Improvements
- [ ] Custom domain with Route 53
- [ ] AWS WAF for security
- [ ] X-Ray distributed tracing
- [ ] Enhanced CloudWatch dashboards
- [ ] Cross-region replication
- [ ] Blue-green deployments
- [ ] Canary releases
- [ ] Automated testing in CI/CD
- [ ] Performance optimization
- [ ] Cost allocation tags

### Scalability Considerations
- API Gateway caching
- Lambda reserved concurrency
- DynamoDB global tables
- Multi-region CloudFront
- Enhanced monitoring
