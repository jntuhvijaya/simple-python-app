#!/bin/bash

set -e

APP_DIR="/home/ubuntu/simple-python-app"
VENV_DIR="$APP_DIR/venv"
SERVICE_FILE="/etc/systemd/system/simple-python-app.service"

echo "Starting Flask application..."

echo "Changing ownership..."
chown -R ubuntu:ubuntu "$APP_DIR"

echo "Installing Python virtual environment support..."
apt-get update
apt-get install -y python3-venv

echo "Creating virtual environment..."

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

echo "Installing Python dependencies..."
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install -r "$APP_DIR/requirements.txt"

echo "Creating systemd service..."

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Simple Python Flask Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=$APP_DIR
ExecStart=$VENV_DIR/bin/gunicorn --bind 0.0.0.0:8000 app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
systemctl daemon-reload

echo "Enabling application service..."
systemctl enable simple-python-app.service

echo "Starting application..."
systemctl restart simple-python-app.service

echo "Checking application status..."
systemctl --no-pager status simple-python-app.service

echo "Application started successfully."
