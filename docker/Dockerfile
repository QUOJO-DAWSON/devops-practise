# Multi-stage build for optimized image size
# Stage 1: Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY . .

# Build the application (if needed)
RUN npm run build || true

################################################################################
# Stage 2: Runtime stage
FROM node:18-alpine AS runtime

# Install security updates and required packages
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
        curl \
        tini \
        dumb-init && \
    rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy built application from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000

# Expose application port
EXPOSE 3000

# Use non-root user
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Use tini for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start application
CMD ["node", "dist/server.js"]

# Build-time metadata
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.title="DevOps Practice App" \
      org.opencontainers.image.description="Sample application for DevOps practices" \
      org.opencontainers.image.url="https://github.com/QUOJO-DAWSON/devops-practise" \
      org.opencontainers.image.source="https://github.com/QUOJO-DAWSON/devops-practise" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.vendor="QUOJO DAWSON" \
      org.opencontainers.image.licenses="MIT"
