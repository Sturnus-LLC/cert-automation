#!/bin/bash

# Validate domain parameter is set
if [ -z "$DOMAINS" ]; then
    echo "Error: DOMAINS environment variable must be set"
    echo "Usage: docker run -e DOMAINS=example.com,www.example.com -v /path/to/ssl:/ssl-certs your-image-name"
    exit 1
fi

# Generate initial certificates
/opt/ssl-scripts/generate_certs.sh

# Start cron to handle renewals
cron -f