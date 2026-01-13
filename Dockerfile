# -------- Stage 1: Build/Lint --------
# Using a specific version instead of 'latest' for reproducibility
FROM nginxinc/nginx-unprivileged:1.25-alpine AS builder

# Set a working directory
WORKDIR /app

# Copy source and set permissions immediately
COPY --chown=101:101 index.html .

# -------- Stage 2: Final Hardened Runtime --------
FROM nginxinc/nginx-unprivileged:1.25-alpine

# Metadata for better tracking
LABEL maintainer="DevOps Team" \
      project="Dice Game" \
      security.hardened="true"

# 1. Clean up default Nginx files to reduce attack surface
USER root
RUN rm -rf /usr/share/nginx/html/* && \
    rm -rf /etc/nginx/conf.d/default.conf
USER 101

# 2. Copy a custom, minimal Nginx config (optional but recommended)
# COPY nginx.conf /etc/nginx/nginx.conf

# 3. Copy only the static content from builder
COPY --from=builder --chown=101:101 /app/index.html /usr/share/nginx/html/index.html

# 4. Security: Ensure the user cannot write to the webroot (Immutable)
USER root
RUN chmod 444 /usr/share/nginx/html/index.html
USER 101

# 5. Healthcheck: Built-in Docker health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:8080/ || exit 1

EXPOSE 8080

# No need for CMD, it's inherited from the base image
