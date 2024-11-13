#!/bin/sh

set -e  # Exit on any error

TARGET_EDGE_FOLDER="/var/coda"
TEMP_FOLDER="/tmp"
TARGET_ARCH="amd64" # amd64, arm64, arm5, arm7
DEFAULT_COMPANY_ID="telus"
INSTALLER_FILES_URL="http://oxygen-coda-installer-files.s3-website-us-east-1.amazonaws.com"

# Function to log success messages
log_success() {
    echo "$1"
}

# Function to handle errors
handle_error() {
    echo "ERROR: $1" >&2
    exit 1
}

echo "================================================="
echo "== Installing EdgeIQ Coda to the Oxygen Device =="
echo "================================================="

# Prompt for Company ID
echo "Enter Company ID (default: ${DEFAULT_COMPANY_ID}):"
read -r company_id
company_id=${company_id:-$DEFAULT_COMPANY_ID}

# Create temp folder if it doesn't exist
[ -d "${TEMP_FOLDER}" ] || mkdir -p "${TEMP_FOLDER}" || handle_error "Failed to create temp folder"

# Download and install CA certificates
if curl --retry 10 --fail -o /etc/ssl/certs/ca-certificates.pem "${INSTALLER_FILES_URL}/cacert-2024-09-24.pem"; then
    log_success "CA certificates downloaded & installed"
else
    handle_error "Failed to download CA certificates"
fi

# Create installation folder
mkdir -p "${TARGET_EDGE_FOLDER}" || handle_error "Failed to create installation folder"
log_success "Installation folder created at ${TARGET_EDGE_FOLDER}"

# Download assets
if curl --retry 10 -o "${TARGET_EDGE_FOLDER}/edge-assets-latest.tar.gz" "https://api.edgeiq.io/api/v1/platform/downloads/latest/edge-assets-latest.tar.gz"; then
    log_success "Assets Downloaded to ${TARGET_EDGE_FOLDER}/edge-assets-latest.tar.gz"
else
    handle_error "Failed to download assets"
fi

# Extract assets
if tar -xzf "${TARGET_EDGE_FOLDER}/edge-assets-latest.tar.gz" -C "${TEMP_FOLDER}/" && \
   mv "${TEMP_FOLDER}/edge/"* "${TARGET_EDGE_FOLDER}/" && \
   rm -rf "${TEMP_FOLDER}/edge"; then
    log_success "Assets Extracted to ${TARGET_EDGE_FOLDER}"
else
    handle_error "Failed to extract assets"
fi

# Configure company ID
if sed -i "s/\(\"company_id\": *\)\"[^\"]*\"/\1\"${company_id}\"/" "${TARGET_EDGE_FOLDER}/conf/bootstrap.json"; then
    log_success "Company ID configured to ${company_id}"
else
    handle_error "Failed to configure company ID"
fi

# Download edge binary
if curl --retry 10 -o "${TARGET_EDGE_FOLDER}/edge" "https://api.edgeiq.io/api/v1/platform/downloads/latest/edge-linux-${TARGET_ARCH}-latest"; then
    log_success "Edge binary downloaded to ${TARGET_EDGE_FOLDER}/edge"
else
    handle_error "Failed to download edge binary"
fi

# Make edge binary executable
chmod +x "${TARGET_EDGE_FOLDER}/edge" || handle_error "Failed to make edge binary executable"
log_success "Made edge binary executable"

# Download init.d script
if curl --retry 10 --fail -o /etc/init.d/coda "${INSTALLER_FILES_URL}/coda"; then
    log_success "Coda init.d script downloaded to /etc/init.d/coda"
else
    handle_error "Failed to download init.d script"
fi

# Make init.d script executable
chmod +x /etc/init.d/coda || handle_error "Failed to make init.d script executable"
log_success "Made coda init.d script executable"

# Start coda service
if /etc/init.d/coda start; then
    log_success "Coda started successfully"
else
    handle_error "Failed to start Coda"
fi

# Add coda service to startup via cron
if (crontab -l 2>/dev/null | grep -q "@reboot /etc/init.d/coda restart"); then
    log_success "Coda startup cron job already exists"
else
    (crontab -l 2>/dev/null; echo "@reboot /etc/init.d/coda restart") | crontab - && \
    log_success "Added coda startup cron job" || \
    handle_error "Failed to add coda startup cron job"
fi

echo "========================================"
echo "== EdgeIQ Coda Installed Successfully =="
echo "========================================"
echo "You can find your Device Unique ID (client id) in the coda logs, using following command:"
echo "tail -n 1000 -f /var/log/coda.log"
echo "========================================"
echo "You can check the status of the Coda service using following command:"
echo "sudo /etc/init.d/coda status"
echo "========================================"