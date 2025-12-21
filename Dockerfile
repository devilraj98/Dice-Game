# Use official lightweight NGINX image
FROM nginx:alpine

# Remove the default NGINX website
RUN rm -rf /usr/share/nginx/html/*

# Copy your website (HTML, CSS, JS) into NGINX web directory
COPY . /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start NGINX server
CMD ["nginx", "-g", "daemon off;"]
