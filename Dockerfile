# Multi-stage production container build for CloudGuard
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source code and static assets
COPY backend ./backend
COPY public ./public
COPY test_data ./test_data

# Create data and storage mount directories with appropriate permissions
RUN mkdir -p data storage/incoming storage/processed storage/quarantine && \
    chown -R node:node /app

USER node

EXPOSE 5000

ENV PORT=5000 \
    NODE_ENV=production \
    STORAGE_PROVIDER=local

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/api/health || exit 1

CMD ["node", "backend/src/server.js"]
