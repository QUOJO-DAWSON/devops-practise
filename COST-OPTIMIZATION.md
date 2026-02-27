# Cost Optimization Strategy

## Current Cost Analysis

### Monthly Costs (Free Tier - Month 1-12)
\\\
Service          | Usage              | Cost
-----------------|-------------------|-------
S3               | <1MB storage      | \.00
CloudFront       | <50GB transfer    | \.00
Lambda           | <1M requests      | \.00
API Gateway      | <1M requests      | \.00
DynamoDB         | <25GB storage     | \.00
CloudWatch       | <10 metrics       | \.00
-----------------|-------------------|-------
TOTAL            |                   | \.00/month
\\\

**Current Status:** 100% within AWS Free Tier limits

### Post-Free-Tier Estimates (Month 13+)

Based on 10,000 requests per month:

\\\
Service          | Usage                    | Monthly Cost
-----------------|--------------------------|-------------
S3               | 1MB storage, 500 GET     | \.02
CloudFront       | 1GB transfer             | \.09
Lambda           | 10K invocations          | \.00 (perpetual Free Tier)
API Gateway      | 10K requests             | \.01
DynamoDB         | 10K writes, 20K reads    | \.03
CloudWatch       | 5 metrics, logs          | \.50
-----------------|--------------------------|-------------
TOTAL            |                          | \.65/month
\\\

**Post-Free-Tier:** ~\.65/month with reasonable traffic

### Cost at Scale (100,000 requests/month)

\\\
Service          | Usage                     | Monthly Cost
-----------------|---------------------------|-------------
S3               | 1MB storage, 5K GET       | \.02
CloudFront       | 10GB transfer             | \.85
Lambda           | 100K invocations          | \.00 (perpetual Free Tier)
API Gateway      | 100K requests             | \.10
DynamoDB         | 100K writes, 200K reads   | \.28
CloudWatch       | 5 metrics, logs           | \.00
-----------------|---------------------------|-------------
TOTAL            |                           | \.25/month
\\\

**At Scale:** ~\.25/month for 100K requests

## Optimization Strategies

### 1. Leverage Perpetual Free Tier

**Lambda Free Tier (Perpetual):**
- 1 million requests per month (forever)
- 400,000 GB-seconds compute time per month
- Current usage: <1% of limits

**Strategy:** Lambda costs remain \ indefinitely for portfolio-level traffic.

### 2. Optimize CloudWatch Costs

**Current Approach:**
- 5 custom metrics
- 3 alarms
- Log retention: 30 days

**Cost Reduction:**
- Metrics: ~\.50/month (10 free, then \.30 each)
- Alarms: \.10 each = \.30/month
- Logs: <\.50/month for light usage

**Optimization:**
- Keep only critical alarms (errors, throttles)
- Reduce log retention to 7 days: saves \.25/month
- Delete unused metrics: saves \.30/metric

**Savings:** ~\.50/month

### 3. CloudFront Cost Management

**Current Configuration:**
- All edge locations enabled
- 50GB/month Free Tier transfer

**Post-Free-Tier Optimization:**
- Price Class: Use only North America & Europe (\.085/GB vs \.140/GB for all regions)
- Savings: ~40% on data transfer
- Trade-off: Slightly higher latency for Asia/South America users

**Impact:** \.04 savings on current traffic, more at scale

### 4. DynamoDB Optimization

**Current:**
- On-demand billing
- Point-in-time recovery enabled (free)
- No provisioned capacity

**When to Switch:**
- Stay on-demand until consistent 25+ WCU/RCU usage
- Break-even: ~25,000 writes + 50,000 reads per month
- Current usage: Well below threshold

**Conclusion:** On-demand remains optimal for portfolio traffic patterns.

### 5. S3 Lifecycle Policies

**Implemented:**
- Versioning: 30-day retention
- Old versions automatically deleted

**Additional Optimizations:**
- Intelligent-Tiering: Not needed (<1MB total)
- Glacier archival: Not applicable (no archival needs)

**Current approach is optimal for this use case.**

## Budget Alerts

### Alert Thresholds

**Configured Alerts:**
1. **80% of budget (\.00)** - Warning alert
2. **100% of budget (\.00)** - Critical alert (actual spend)
3. **100% of budget (\.00)** - Critical alert (forecasted spend)

**Monthly Budget:** \.00

**Email:** dawsonkessongp@gmail.com

### Alert Actions

**At 80% (\.00):**
1. Review AWS Cost Explorer for unexpected usage
2. Check CloudWatch metrics for traffic spikes
3. Identify cost drivers

**At 100% (\.00):**
1. Immediate investigation of cost spike
2. Review recent deployments or config changes
3. Consider temporary throttling if abuse detected
4. Evaluate if legitimate traffic growth requires budget increase

### Emergency Cost Controls

**If costs exceed budget unexpectedly:**

1. **Identify source:**
\\\ash
# Check cost by service
aws ce get-cost-and-usage \\
  --time-period Start=2026-02-01,End=2026-02-28 \\
  --granularity DAILY \\
  --metrics UnblendedCost \\
  --group-by Type=DIMENSION,Key=SERVICE
\\\

2. **Immediate actions:**
   - Disable CloudFront distribution (if traffic abuse)
   - Reduce DynamoDB capacity (if provisioned and unused)
   - Delete excessive CloudWatch logs
   - Reduce log retention to 1 day temporarily

3. **Long-term fixes:**
   - Implement API rate limiting
   - Add CloudFront WAF rules (if DDoS)
   - Optimize Lambda memory/timeout if over-provisioned

## Cost Allocation Tags

**Implemented Tags:**
\\\hcl
tags = {
  Project     = "devops-practise"
  Environment = "production"
  ManagedBy   = "terraform"
  Owner       = "george-dawson-kesson"
}
\\\

**Benefits:**
- Track costs by project
- Filter Cost Explorer by tag
- Identify resource ownership
- Support for future multi-project cost analysis

## Cost Comparison vs Traditional Architecture

### Serverless (Current)
\\\
Infrastructure:     \.00/month (Free Tier)
Post-Free-Tier:     \.65/month
Scaling:            Automatic, pay-per-use
Maintenance:        Zero operational overhead
\\\

### Traditional (EC2 + RDS)
\\\
EC2 t3.micro:       \.50/month (Linux, on-demand)
RDS t3.micro:       \.50/month (PostgreSQL)
Data transfer:      \.50/month
Total:              \.50/month minimum
Scaling:            Manual, requires planning
Maintenance:        Patching, backups, monitoring
\\\

**Savings:** \.50 - \.65 = **\.85/month (92% cost reduction)**

### Container-Based (ECS + RDS)
\\\
ECS Fargate:        \.00/month (0.25 vCPU, 0.5GB)
RDS t3.micro:       \.50/month
ALB:                \.20/month
Total:              \.70/month minimum
\\\

**Savings:** \.70 - \.65 = **\.05/month (96% cost reduction)**

### Kubernetes (EKS)
\\\
EKS control plane:  \.00/month
Worker nodes:       \.00/month (2x t3.small)
LoadBalancer:       \.20/month
Total:              \.20/month minimum
\\\

**Savings:** \.20 - \.65 = **\.55/month (99% cost reduction)**

## Monitoring and Reporting

### Cost Tracking Tools

**AWS Cost Explorer:**
- Daily cost breakdown
- Service-level analysis
- Forecasting (3 months ahead)
- Custom reports

**AWS Budgets:**
- Real-time tracking
- Email alerts
- Threshold monitoring

**CloudWatch Metrics:**
- Request count (cost correlation)
- Data transfer volumes
- Lambda invocations

### Monthly Cost Review Process

**First of each month:**
1. Review AWS Cost Explorer for previous month
2. Compare actual vs budgeted costs
3. Identify any anomalies or trends
4. Update budget if needed (growth or optimization)
5. Document findings

**Cost Review Template:**
\\\markdown
## Cost Review - [Month Year]

**Total Spend:** \.XX
**Budget:** \.00
**Variance:** +/- \.XX

**Top Cost Drivers:**
1. Service A: \.XX
2. Service B: \.XX
3. Service C: \.XX

**Anomalies:**
- [Any unexpected costs]

**Actions:**
- [Optimization steps taken]
\\\

## Future Optimizations

### When Traffic Grows

**At 50K requests/month:**
- Consider API Gateway caching (\.02/hour = \.40/month)
- Trade-off: Reduces Lambda/DynamoDB costs but adds caching cost
- Evaluate based on cache hit ratio

**At 100K+ requests/month:**
- Switch DynamoDB to provisioned capacity
- Savings: ~\/month vs on-demand at this scale
- Requires capacity planning

**At 1M+ requests/month:**
- Lambda Savings Plans (20% discount on commit)
- Reserved CloudFront capacity
- Consider multi-region for global users

### Cost Optimization Checklist

**Quarterly Review:**
- [ ] Audit unused resources
- [ ] Review Lambda memory allocation (right-sizing)
- [ ] Check CloudWatch log retention
- [ ] Analyze DynamoDB on-demand vs provisioned
- [ ] Review CloudFront price class
- [ ] Delete old S3 versions
- [ ] Optimize CloudWatch alarms (remove unused)

**Annual Review:**
- [ ] Evaluate Savings Plans eligibility
- [ ] Review Reserved Capacity options
- [ ] Assess architecture changes for cost efficiency
- [ ] Update budget based on traffic growth

## Conclusion

The serverless architecture achieves exceptional cost efficiency:
- **Current:** \.00/month (100% Free Tier)
- **Post-Free-Tier:** \.65/month
- **At Scale:** \.25/month (100K requests)

Cost optimization is built into the architecture through:
- Pay-per-use pricing (no idle costs)
- Perpetual Lambda Free Tier
- Automatic scaling without over-provisioning
- Minimal operational overhead

The \/month budget provides 3x headroom for traffic growth while maintaining proactive cost monitoring through AWS Budgets alerts.
