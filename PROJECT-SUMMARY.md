# Project Summary

## What This Is

Over the past few weeks, I built a complete serverless infrastructure on AWS to demonstrate what I can do with modern DevOps tools and practices. The goal was to create something production-ready, not just a tutorial project, while keeping costs at zero using the AWS Free Tier.

## The Technical Stack

I deployed a serverless website with a visitor counter API. It uses CloudFront for global distribution, Lambda for serverless compute, DynamoDB for data persistence, and API Gateway to tie it together. Everything is defined in Terraform so the entire infrastructure can be rebuilt from scratch in about 5 minutes.

The backend is Node.js running on Lambda, using AWS SDK v3 to talk to DynamoDB. I added CloudWatch monitoring with alarms that email me if error rates spike or latency gets too high. There's also a test suite that validates the API actually works as expected.

## Why I Built It This Way

**Cost was a big consideration.** Running EC2 instances 24/7 would cost around \/month even for small instances. With serverless, I pay nothing when there's no traffic and only pennies when there is. The whole setup currently costs \.00/month and should stay under \/month even after Free Tier expires.

**I wanted to avoid operational overhead.** No servers to patch, no capacity planning, no worrying about scaling. AWS handles all of that. I can focus on building features instead of maintaining infrastructure.

**The architecture needed to be realistic.** I included things you'd actually need in production like monitoring, disaster recovery procedures, security configurations, and cost controls. It's not just the happy path - I documented what to do when things break.

## Challenges I Ran Into

**Cold starts were painful at first.** The Lambda function was taking 400ms to wake up because I was loading the entire AWS SDK v2 (around 50MB). I spent time profiling this, switched to SDK v3 with tree-shaking to only include the DynamoDB client, and got cold starts down to 200ms. That's still not instant, but acceptable for a portfolio site.

**CORS tripped me up initially.** The browser was blocking my API calls even though everything seemed configured correctly. Turns out I needed to handle preflight OPTIONS requests properly and set the right headers. After reading through the AWS docs and some Stack Overflow threads, I got it working.

**CloudFront caching caused confusion.** I'd update the website files in S3 but the changes wouldn't show up for hours. Learned I needed to invalidate the CloudFront cache after deployments. Now I know to either use cache invalidation or implement cache-busting with versioned filenames.

These weren't theoretical problems I read about - I actually hit them and had to figure out solutions.

## What I Learned

**Infrastructure as Code is powerful.** Being able to version control infrastructure like application code makes a huge difference. I can review changes, roll back if needed, and rebuild everything from scratch. It's way better than clicking through the AWS console.

**Serverless has trade-offs.** Cold starts are real, you have less control over the runtime environment, and debugging can be trickier. But for the right use case, the benefits outweigh the downsides. No idle costs and automatic scaling are hard to beat.

**Documentation matters.** I spent almost as much time documenting as coding. Future me (or anyone else) can read the disaster recovery runbook and know exactly what to do if DynamoDB fails or the whole infrastructure gets accidentally deleted.

**Cost optimization isn't an afterthought.** I set up budget alerts from the beginning and documented the cost of every architectural decision. Choosing on-demand DynamoDB over provisioned capacity, HTTP API over REST API, serverless over containers - each choice had a cost implication.

## The Development Process

I didn't build this all at once. The first couple days were spent getting basic infrastructure deployed. Then I iteratively added security configurations, disaster recovery procedures, performance optimizations, testing, and cost monitoring over the next few weeks.

Each improvement got its own commit with a clear message explaining what changed and why. The commit history tells the story of how the project evolved, which I think shows how I'd actually work on a team.

## Key Results

The infrastructure runs at **\.00/month** right now and should cost around **\.65/month** after the Free Tier expires. That's compared to \-120/month for traditional server-based setups.

Lambda cold starts went from 400ms down to 200ms through dependency optimization. API response times for warm requests are around 45ms. The whole stack has 99.99% availability because it's all managed services.

I wrote about 500 lines of Terraform, 150 lines of JavaScript, and over 2000 lines of documentation. Everything is tested, monitored, and ready to handle real traffic.

## Where I'd Take This Next

If I were continuing to build on this foundation:

**Add observability.** I'd implement distributed tracing with AWS X-Ray to understand request flows and identify bottlenecks. Right now I just have logs and metrics.

**Implement CI/CD properly.** There's a basic GitHub Actions workflow but I'd expand it to include automated testing, security scanning, and deployment approvals for production.

**Multi-region deployment.** For truly global applications, I'd deploy to multiple regions with Route 53 health checks for automatic failover.

**More sophisticated testing.** The current test suite validates happy paths. I'd add error injection, load testing, and chaos engineering to validate resilience.

## Skills This Demonstrates

From a DevOps perspective, this project shows I can work with Terraform, AWS services, monitoring tools, and CI/CD pipelines. I understand how to optimize for cost and performance while maintaining security and reliability.

From a broader engineering perspective, it shows I think about operations, not just development. I documented disaster recovery procedures, set up monitoring before problems occurred, and made architectural trade-offs based on actual requirements.

Most importantly, it shows I can take a project from concept to production-ready deployment with professional practices throughout.

## Repository Stats

- **Commits:** 17 over 18 days
- **Documentation:** 111 markdown files
- **Code:** 500+ lines Terraform, 150+ lines JavaScript
- **Cost:** \.00/month
- **AWS Services:** 6 services integrated

---

**Contact:** dawsonkessongp@gmail.com  
**Location:** Hamilton, Ohio  
**Certification:** AWS Certified Solutions Architect - Associate  
**Completed:** February 2026
