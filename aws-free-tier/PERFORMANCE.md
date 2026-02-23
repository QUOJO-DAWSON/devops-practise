# Performance Optimization

## Lambda Optimization (Implemented)

### Memory Allocation
- **Before:** 128 MB
- **After:** 256 MB
- **Reason:** Better CPU allocation, faster execution
- **Cost impact:** Minimal (still within Free Tier)

### Timeout Configuration
- **Before:** 10 seconds
- **After:** 15 seconds
- **Reason:** Handle occasional DynamoDB latency spikes
- **Cost impact:** None (only charged for actual execution time)

### Environment Variables
Added configuration via environment variables:
- TABLE_NAME: DynamoDB table name
- NODE_ENV: production
- LOG_LEVEL: info

### Cold Start Mitigation
- Minimal dependencies (AWS SDK v3 only)
- No large libraries or frameworks
- Simple, focused function
- Typical cold start: < 200ms

## DynamoDB Optimization

### On-Demand Capacity
- Automatically scales with traffic
- No provisioned capacity waste
- Pay only for actual reads/writes
- Perfect for variable traffic patterns

### Single-Table Design
- One table for visitor counter
- Simple partition key
- No complex queries needed
- Low latency (<10ms typical)

## CloudFront Optimization

### Cache Behavior
- Static assets cached at edge
- TTL: 86400 seconds (24 hours)
- Reduces origin requests
- Improves global latency

### Compression
- Gzip compression enabled
- Reduces bandwidth costs
- Faster page loads
- Better user experience

## Results

### Before Optimization
- Lambda cold start: ~400ms
- Lambda memory: 128 MB
- Warm execution: ~50ms
- Cost: \.00/month

### After Optimization
- Lambda cold start: ~200ms (50% improvement)
- Lambda memory: 256 MB
- Warm execution: ~45ms
- Cost: \.00/month (no change)

### Key Improvements
- Cold start reduced by 200ms through dependency optimization
- AWS SDK v3 with tree-shaking cut bundle size from 50MB to 3MB
- Better CPU allocation with 256MB memory speeds up initialization
- Maintained zero cost while improving performance

## Lessons Learned

I discovered that Lambda cold starts were the biggest performance bottleneck. The initial 400ms delays were caused by loading the full AWS SDK v2 (50MB). Migrating to AWS SDK v3 and using tree-shaking to include only the DynamoDB client reduced the bundle to just 3MB. This cut dependency load time from 150ms to 80ms.

Increasing memory from 128MB to 256MB also helped because Lambda allocates CPU proportionally to memory. More memory meant faster code initialization, even though the function itself doesn't use much memory. The cost stayed at \ because faster execution offset the higher memory pricing.

For production applications with strict latency requirements, I'd consider provisioned concurrency to eliminate cold starts entirely, but that costs about \/month. For a portfolio site, the occasional 200ms delay is acceptable.

## Future Optimizations

### Planned Improvements
- Lambda provisioned concurrency (eliminate cold starts)
- DynamoDB DAX caching layer
- CloudFront cache key optimization
- Lambda@Edge for dynamic content
- X-Ray tracing for performance insights
- API Gateway caching

### Monitoring
- CloudWatch metrics dashboard
- Performance alarms
- Cost optimization alerts
- Usage pattern analysis

## Performance Testing

### Test Methodology
I tested cold starts by letting the function go idle for 15 minutes, then making a request. Warm starts were tested by making consecutive requests within 5 minutes. All tests ran from my local machine in Hamilton, Ohio to the us-east-2 region.

### Test Results
- Cold start (128MB): 380-420ms (avg: 400ms)
- Cold start (256MB): 180-220ms (avg: 200ms)
- Warm execution: 40-50ms (avg: 45ms)
- DynamoDB latency: 5-10ms (avg: 7ms)

### Real-World Impact
For portfolio visitors, the cold start only affects the first request after 15 minutes of inactivity. Since most visitors view the site during active periods, they experience the 45ms warm execution time. The 200ms cold start is acceptable for a \/month infrastructure.
