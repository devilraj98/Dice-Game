# -------- Stage 1: Build --------
FROM nginx:alpine AS build

WORKDIR /usr/share/nginx/html
COPY index.html .

# -------- Stage 2: Runtime --------
FROM nginx:alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only required files
COPY --from=build /usr/share/nginx/html /usr/share/nginx/html

# Change ownership
RUN chown -R appuser:appgroup /usr/share/nginx/html

USER appuser

EXPOSE 80
