#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
echo "Script dir: $SCRIPT_DIR"

# ----------------------------------------------------------------------
# Paths
# ----------------------------------------------------------------------
CONF_TEMPLATE="$SCRIPT_DIR/nginx.conf.in"
CONF_PATH="$SCRIPT_DIR/nginx.conf"
SYS_CONF_PATH="/etc/nginx/nginx.conf"
SSL_DIR="$SCRIPT_DIR/ssl"
SSL_KEY="$SSL_DIR/localhost.key"
SSL_CERT="$SSL_DIR/localhost.crt"

# ----------------------------------------------------------------------
# Generate nginx.conf
# ----------------------------------------------------------------------
ROOT="$SCRIPT_DIR" envsubst '$ROOT $HOME' \
    < "$CONF_TEMPLATE" \
    > "$CONF_PATH"
echo "Create: $CONF_PATH"

# ----------------------------------------------------------------------
# Add include to system nginx.conf only once
# ----------------------------------------------------------------------
INCLUDE_LINE="    include $CONF_PATH;"
if sudo grep -Fqx "$INCLUDE_LINE" "$SYS_CONF_PATH"; then
    echo "Include already exists: $CONF_PATH"
else
    # Escape characters relevant to sed replacement.
    ESCAPED_INCLUDE="$(printf '%s\n' "$INCLUDE_LINE" | sed 's/[&/\]/\\&/g')"

    sudo sed -i \
        "/^[[:space:]]*http[[:space:]]*{/a\\
$ESCAPED_INCLUDE
" \
        "$SYS_CONF_PATH"
    echo "Add include: $CONF_PATH"
fi

# ----------------------------------------------------------------------
# Create SSL certificate only if it does not already exist
# ----------------------------------------------------------------------
mkdir -p "$SSL_DIR"
if [[ -f "$SSL_KEY" && -f "$SSL_CERT" ]]; then
    echo "SSL already exists: $SSL_DIR"
else
    echo "Create SSL: $SSL_DIR"

    openssl req -nodes -x509 -sha256 \
        -newkey rsa:4096 \
        -keyout "$SSL_KEY" \
        -out "$SSL_CERT" \
        -days 365 \
        -subj "/CN=localhost" \
        -addext "subjectAltName = DNS:localhost"
fi

# ----------------------------------------------------------------------
# Validate nginx configuration
# ----------------------------------------------------------------------
echo "Testing nginx configuration..."
sudo nginx -t

# ----------------------------------------------------------------------
# Enable and restart nginx
# ----------------------------------------------------------------------
sudo systemctl enable nginx.service
sudo systemctl restart nginx.service

echo "Nginx restarted successfully."

sudo systemctl --no-pager --full status nginx.service
