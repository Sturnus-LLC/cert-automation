#!/bin/bash

# Exit on any error
set -e

# Check if domains are provided
if [ -z "$DOMAINS" ]; then
    echo "Error: No domains specified. Please provide domains as a comma-separated list."
    exit 1
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
        --cert-path "$domain_dir/cert.pem" \
        --key-path "$domain_dir/privkey.pem" \
        --fullchain-path "$domain_dir/fullchain.pem"
    
    echo "Generated certificates for $domain"
done

# List generated certificates
echo "Generated certificates:"
find /ssl-certs -type f | grep -E '(cert.pem|privkey.pem|fullchain.pem)'