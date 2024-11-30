#Cert Automation Utility
##Overview
This Docker container automates the process of generating and renewing SSL certificates using Let's Encrypt's Certbot for multiple domains.

##Features
-Generate SSL certificates for multiple domains
-Automatically renew certificates
-Store certificates in separate directories for each domain
-Scheduled renewal via cron

##Prerequisites
-Docker installed
-Ports 80 and 443 available (used by Certbot for domain validation)
-Domains pointing to the server where this container will run

##Usage
-Build the Docker Image
```bash
docker build -t ssl-cert-generator .
```

##Run the Container
```bash
docker run -d \
  -e DOMAINS="example.com,www.example.com,another-domain.com" \
  -v /volume/and/folders/ssl-certs:/ssl-certs \
  -p 80:80 \
  -p 443:443 \
  ssl-cert-generator
```

##Parameters
-```DOMAINS```: Comma-separated list of domains to generate certificates for
-```-v /path/on/host/ssl-certs:/ssl-certs```: Volume mount to persist certificates
-```-p 80:80 -p 443:443```: Expose ports for Let's Encrypt domain validation

##Certificate Storage
Certificates for each domain will be stored in ```/ssl-certs/DOMAIN_NAME/```:
-```cert.pem```: Domain certificate
-```privkey.pem```: Private key
-```fullchain.pem```: Full certificate chain

##Renewal
-Automatic renewal attempts occur twice daily via cron
-Certificates are renewed if they are close to expiration

##Important Notes
-Ensure domains point to the server running this container
-First-time run requires internet access to validate domains
-Let's Encrypt has rate limits, so be cautious with frequent regenerations

##Troubleshooting
-Check container logs for any certificate generation errors
-Ensure ports 80 and 443 are not blocked by firewall
-Verify domain ownership and DNS settings