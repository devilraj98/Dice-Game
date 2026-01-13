# -------- Runtime Image (Kubernetes-Stable) --------
FROM nginxinc/nginx-unprivileged:1.25-alpine

# Metadata
LABEL maintainer="DevOps Team" \
      project="Dice Game" \
      runtime="kubernetes-stable"

# Copy static content
# nginx-unprivileged already runs as UID 101
COPY --chown=101:101 index.html /usr/share/nginx/html/index.html

# Expose the unprivileged port
EXPOSE 8080

# NOTE:
# - We do NOT delete default.conf
# - We do NOT chmod webroot
# - We do NOT add Docker HEALTHCHECK
# Kubernetes handles health via probes
