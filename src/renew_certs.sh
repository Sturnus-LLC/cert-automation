#!/bin/bash

# Exit on any error
set -e

# Check if domains are provided
if [ -z "$DOMAINS" ]; then
    echo "Error: No domains specified. Skipping renewal."
    exit 1
fi

# Convert comma-separated domains to an array
IFS=',' read -ra DOMAIN_ARRAY <<< "$DOMAINS"

# Renewal flags array
RENEWAL_ARGS=()

# Prepare renewal arguments for each domain
for domain in "${DOMAIN_ARRAY[@]}"; do
    # Trim whitespace
    domain=$(echo "$domain" | xargs)
    
    # Add domain to renewal arguments
    RENEWAL_ARGS+=("-d" "$domain")
done

# Attempt to renew certificates
certbot renew \
    --standalone \
    --non-interactive \
    "${RENEWAL_ARGS[@]}" \
    --cert-path /ssl-certs \
    --key-path /ssl-certs

# Log renewal attempt
echo "Certificate renewal attempted at $(date)"