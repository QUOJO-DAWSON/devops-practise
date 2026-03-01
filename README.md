# DevOps Practice Repository

## Status

![Terraform](https://img.shields.io/badge/Terraform-1.14+-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Free_Tier-FF9900?logo=amazon-aws&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?logo=node.js&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue.svg)
![Cost](https://img.shields.io/badge/Cost-%240%2Fmonth-success)

## Quick Links

- [Architecture Documentation](ARCHITECTURE.md)
- [Disaster Recovery Plan](DISASTER-RECOVERY.md)
- [Performance Optimization](PERFORMANCE.md)
- [Cost Analysis](COST-OPTIMIZATION.md)
- [Development Notes](DEVELOPMENT.md)
- [API Tests](aws-free-tier/tests/)

---

## What This Is

A production-ready serverless infrastructure built on AWS, demonstrating practical DevOps skills I've developed. Everything is deployed using Terraform and currently runs at zero cost within the AWS Free Tier.

**Live site:** https://d2z0w8iz0rhvdj.cloudfront.net

## The Stack

I built this using entirely serverless AWS services:

**Frontend**
- S3 for static website hosting
- CloudFront as a global CDN

**Backend**
- Lambda functions (Node.js 18)
- API Gateway for the REST API
- DynamoDB for data persistence

**Operations**
- CloudWatch for monitoring and alerts
- AWS Budgets to track costs

Everything is defined in Terraform - about 500 lines of code that can rebuild the entire infrastructure from scratch in around 5 minutes.

## Why Serverless?

I chose a serverless architecture for a few practical reasons. First, cost - this runs at \/month now and should cost around \.65/month even after Free Tier expires. Compare that to \+/month for traditional EC2 and RDS setups. Second, I wanted zero operational overhead. No servers to patch, no capacity planning, no worrying about scaling. Third, it's what I'd actually recommend for this type of workload in a real job.

## What I Learned

**Cold starts were frustrating.** My Lambda function was taking 400ms to wake up because I was loading the entire AWS SDK v2 bundle (50MB). I profiled it, switched to SDK v3 with tree-shaking, and cut the bundle down to 3MB. Cold starts dropped to 200ms.

**CORS is trickier than it looks.** The browser kept blocking my API calls even though everything seemed configured right. Spent time reading the AWS docs and Stack Overflow to understand preflight OPTIONS requests and proper header configuration.

**Infrastructure as Code is powerful.** Being able to version control infrastructure just like application code makes a huge difference. I can review changes, roll back mistakes, and rebuild everything from scratch if needed.

**Documentation matters more than I thought.** I spent nearly as much time writing docs as writing code. But now anyone (including future me) can understand the architecture, recover from failures, and know why I made certain decisions.

## The Cost Story

One thing I'm proud of is the cost efficiency. Here's how it breaks down:

**Current (Free Tier):** \.00/month  
**After Free Tier:** \.65/month  
**Traditional EC2/RDS equivalent:** \/month  
**Savings:** 97%

I documented the entire cost analysis in [COST-OPTIMIZATION.md](COST-OPTIMIZATION.md) including budget alerts and what to do if costs spike unexpectedly.

## Monitoring & Reliability

The infrastructure includes CloudWatch alarms that email me if:
- Error rates exceed 5%
- API latency hits 1000ms
- Lambda functions get throttled

DynamoDB has point-in-time recovery enabled so I can restore to any second in the last 35 days. S3 has versioning turned on. Everything critical is documented in the disaster recovery plan.

## Project Structure

\\\
devops-practise/
 aws-free-tier/
    terraform/              # All infrastructure code
       main.tf
       cloudwatch-alarms.tf
       security.tf
       cost-monitoring.tf
    lambda/                 # Serverless functions
       index.js
    website/                # Static site
       index.html
    tests/                  # Integration tests
        api-tests.js
        README.md
 ARCHITECTURE.md             # How everything works
 DISASTER-RECOVERY.md        # What to do when things break
 PERFORMANCE.md              # Cold start optimizations
 COST-OPTIMIZATION.md        # Cost analysis and budgets
 DEVELOPMENT.md              # Development approach
\\\

## Getting Started

If you want to deploy this yourself:

\\\ash
# Deploy infrastructure
cd aws-free-tier/terraform
terraform init
terraform apply

# Run tests
cd ../tests
node api-tests.js
\\\

You'll need AWS CLI configured and Terraform installed.

## The Numbers

- **AWS Services:** 6 (S3, CloudFront, Lambda, API Gateway, DynamoDB, CloudWatch)
- **Infrastructure Code:** 500+ lines of Terraform
- **Documentation:** 2000+ lines across 5 major docs
- **Current Cost:** \.00/month
- **Performance:** <200ms cold start, <50ms warm requests

## Technologies

**Cloud:** AWS  
**IaC:** Terraform  
**Runtime:** Node.js 18.x  
**Database:** DynamoDB  
**CI/CD:** GitHub Actions  
**Monitoring:** CloudWatch  

## Documentation

I've documented everything pretty thoroughly:

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - How all the pieces fit together
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - My iterative development approach
- **[PERFORMANCE.md](PERFORMANCE.md)** - Cold start optimization work
- **[DISASTER-RECOVERY.md](DISASTER-RECOVERY.md)** - Recovery procedures for 6 failure scenarios
- **[COST-OPTIMIZATION.md](COST-OPTIMIZATION.md)** - Complete cost breakdown and monitoring

## License

MIT License - see [LICENSE](LICENSE) file.

## Contact

**George Dawson-Kesson**

- GitHub: [@QUOJO-DAWSON](https://github.com/QUOJO-DAWSON)
- LinkedIn: [linkedin.com/in/gdawsonkesson](https://www.linkedin.com/in/gdawsonkesson)
- Email: dawsonkessongp@gmail.com

---

Built in Hamilton, Ohio. AWS Certified Solutions Architect - Associate.
