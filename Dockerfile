FROM node:20-alpine AS builder
WORKDIR /app

# Install pnpm
RUN corepack enable

# Copy and Install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy source and build the application
COPY . .
RUN pnpm build

# --- runtime ---
FROM node:20-alpine

# Install curl during the image build process
RUN apk update && apk add curl

RUN addgroup -S appgroup && adduser -S -G appgroup -u 1001 appuser
WORKDIR /app

COPY --from=builder --chown=appuser:appgroup /app/.next/standalone ./
COPY --from=builder --chown=appuser:appgroup /app/.next/static .next/static
COPY --from=builder --chown=appuser:appgroup /app/public public

EXPOSE 3000
USER appuser
CMD ["node", "server.js"]
