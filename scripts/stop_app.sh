#!/bin/bash

echo "Stopping Flask application..."

systemctl stop simple-python-app.service || true

echo "Application stopped."
