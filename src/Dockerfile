# Use Ubuntu as the base image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    certbot \
    cron \
    nginx \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Create directories for scripts
RUN mkdir -p /opt/ssl-scripts

# Copy the certificate generation and renewal scripts
COPY ./sh/generate_certs.sh /opt/ssl-scripts/generate_certs.sh
COPY ./sh/renew_certs.sh /opt/ssl-scripts/renew_certs.sh

# Make scripts executable
RUN chmod +x /opt/ssl-scripts/*.sh

# Set up crontab for certificate renewal
RUN (crontab -l 2>/dev/null; echo "0 0,12 * * * /opt/ssl-scripts/renew_certs.sh") | crontab -

# Volume for storing SSL certificates
VOLUME ["/ssl-certs"]

# Copy entrypoint script
COPY ./sh/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]