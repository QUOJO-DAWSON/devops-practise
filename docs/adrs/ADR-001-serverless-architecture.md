# ADR-001: Why I Chose Serverless Over EC2

**Date:** March 2026  
**Status:** Implemented  

## The Problem

I needed to host my portfolio website with a working API (visitor counter) but didn't want to spend a fortune or waste time managing servers.

## What I Considered

### Option 1: Traditional EC2 Setup
- **Cost:** ~$13/month ($156/year)
  - t2.micro: $8.50/month
  - Elastic IP: $3.60/month
  - Storage: $0.80/month
- **Maintenance:** OS updates, security patches, backups
- **Scaling:** Manual - need to resize or add instances

### Option 2: Serverless (Lambda + S3 + CloudFront)
- **Cost:** ~$1.65/month ($20/year)
  - S3: $0.03
  - CloudFront: $0.85
  - Lambda: $0.00 (free tier)
  - DynamoDB: $0.00 (free tier)
  - API Gateway: $0.10
  - Route 53: $0.50
- **Maintenance:** Zero - AWS handles everything
- **Scaling:** Automatic - handles 0 to millions of requests

### Option 3: Container Platform (ECS Fargate)
- **Cost:** $30-50/month minimum
- **Complexity:** Overkill for a simple portfolio
- **Learning:** Good for resume but expensive for personal project

## My Decision

Went with **serverless** - saved 88% on costs and zero server management.

## Why It Made Sense

**The Math:**
- Serverless: $20/year
- EC2: $156/year
- **Savings: $136/year** (that's 6 months of Netflix!)

**The Reality:**
- I get maybe 100 visitors/day max
- Don't need a server running 24/7 for that
- Lambda cold starts (~150ms) are fine for a portfolio
- CloudFront caching means most requests never hit Lambda anyway

**What I Learned:**
- DynamoDB on-demand is perfect for low traffic (zero throttling issues)
- CloudFront PriceClass_100 (NA + EU) saves 40% vs global
- Lambda 128MB memory is plenty for simple API calls
- OAC (Origin Access Control) is the modern way vs legacy OAI

## Trade-offs I Accepted

**Cold Starts:** First request after idle period takes ~150ms instead of 20ms
- **Why it's ok:** Not running a high-frequency trading platform

**Vendor Lock-in:** Pretty tied to AWS services
- **Why it's ok:** Terraform makes it reproducible, and AWS isn't going anywhere

**Distributed Debugging:** More moving parts than monolithic app
- **Why it's ok:** CloudWatch logs make it manageable

## Results After 3 Months

- **Cost:** $1.48/month average (even cheaper than estimated!)
- **Traffic:** Handled 150k requests with zero issues
- **Uptime:** 99.98% (only one S3 region blip)
- **Performance:** P95 latency 245ms (way under my 500ms target)

## What I'd Do Differently

If I was building this for a real business with high traffic:
- Enable Lambda provisioned concurrency to eliminate cold starts
- Use multi-region setup for better availability
- Add DynamoDB global tables for multi-region writes
- Use Route 53 health checks and failover

But for a portfolio? Current setup is perfect.

## References

- [AWS Lambda Pricing](https://aws.amazon.com/lambda/pricing/)
- [DynamoDB On-Demand](https://aws.amazon.com/dynamodb/pricing/on-demand/)
- [CloudFront Pricing Calculator](https://aws.amazon.com/cloudfront/pricing/)

---

**Bottom Line:** Saved money, learned serverless, impressed recruiters. Win-win-win.