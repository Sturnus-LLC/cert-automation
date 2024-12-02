#!/bin/bash

# Exit on any error
set -e

# Check if domains are provided
if [ -z "$DOMAINS" ]; then
    echo "Error: No domains specified. Please provide domains as a comma-separated list."
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

# Create directory for SSL certificates if it doesn't exist
mkdir -p /ssl-certs

# Generate certificates for each domain
for domain in "${DOMAIN_ARRAY[@]}"; do
    # Trim whitespace
    domain=$(echo "$domain" | xargs)
    
    # Create a directory for this domain
    domain_dir="/ssl-certs/$domain"
    mkdir -p "$domain_dir"
    
    # Generate certificate using Certbot
    certbot certonly \
        --standalone \
        --non-interactive \
        --agree-tos \
        --email admin@$domain \
        -d "$domain" \
	--http-01-port $HTTP_PORT \
        --https-port $HTTPS_PORT \
        $STAGING_FLAG
    
    # Copy certificates to the desired location
    cp "/etc/letsencrypt/live/$domain/cert.pem" "$domain_dir/cert.pem"
    cp "/etc/letsencrypt/live/$domain/privkey.pem" "$domain_dir/privkey.pem"
    cp "/etc/letsencrypt/live/$domain/fullchain.pem" "$domain_dir/fullchain.pem"
    
    # Set proper permissions
    chmod 644 "$domain_dir/cert.pem"
    chmod 644 "$domain_dir/fullchain.pem"
    chmod 600 "$domain_dir/privkey.pem"
    
    echo "Generated and copied certificates for $domain"
done

# List generated certificates
echo "Generated certificates in /ssl-certs:"
find /ssl-certs -type f | grep -E '(cert.pem|privkey.pem|fullchain.pem)'
