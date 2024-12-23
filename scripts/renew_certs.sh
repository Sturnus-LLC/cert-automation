#!/bin/bash

# Exit on any error
set -e

# Check if domains are provided
if [ -z "$DOMAINS" ]; then
    echo "Error: No domains specified. Skipping renewal."
    exit 1
fi

# Set default ports if not provided
HTTP_PORT=${HTTP_PORT:-80}
HTTPS_PORT=${HTTPS_PORT:-443}

# Check if we should use staging environment
USE_STAGING=${USE_STAGING:-false}
STAGING_FLAG=""
if [ "$USE_STAGING" = "true" ]; then
    STAGING_FLAG="--test-cert"
    echo "Using Let's Encrypt staging environment"
fi

# Convert comma-separated domains to an array
IFS=',' read -ra DOMAIN_ARRAY <<< "$DOMAINS"

# Attempt to renew certificates
certbot renew \
    --standalone \
    --non-interactive \
    $STAGING_FLAG

# Copy renewed certificates to the custom directories
for domain in "${DOMAIN_ARRAY[@]}"; do
    # Trim whitespace
    domain=$(echo "$domain" | xargs)
    
    domain_dir="/ssl-certs/$domain"
    
    # Only copy if the domain directory exists
    if [ -d "$domain_dir" ]; then
        # Copy renewed certificates
        cp "/etc/letsencrypt/live/$domain/cert.pem" "$domain_dir/cert.pem"
        cp "/etc/letsencrypt/live/$domain/privkey.pem" "$domain_dir/privkey.pem"
        cp "/etc/letsencrypt/live/$domain/fullchain.pem" "$domain_dir/fullchain.pem"
        
        # Set proper permissions
        chmod 644 "$domain_dir/cert.pem"
        chmod 644 "$domain_dir/fullchain.pem"
        chmod 600 "$domain_dir/privkey.pem"
        
        echo "Renewed and copied certificates for $domain"
    fi
done

# Log renewal attempt
echo "Certificate renewal and copy completed at $(date)"
