# -------- Stage 1: Build --------
FROM nginxinc/nginx-unprivileged:alpine AS build
WORKDIR /usr/share/nginx/html
COPY index.html .

# -------- Stage 2: Runtime --------
FROM nginxinc/nginx-unprivileged:alpine

# Copy files from build stage
COPY --from=build /usr/share/nginx/html /usr/share/nginx/html

# No need to create users or change ownership; it's already handled!
EXPOSE 8080
