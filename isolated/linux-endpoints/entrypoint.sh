#!/bin/bash

# Start rsyslog
service rsyslog start

# Start sshd
/usr/sbin/sshd

# Check if Fleet variables are provided via environment
if [ -n "$FLEET_URL" ] && [ -n "$ENROLLMENT_TOKEN" ]; then
    echo "Enrolling Elastic Agent into Fleet..."
    cd /opt/elastic-agent
    ./elastic-agent enroll --url="${FLEET_URL}" --enrollment-token="${ENROLLMENT_TOKEN}" --insecure --delay-enroll --force
    
    echo "Starting Fleet-managed Elastic Agent..."
    ./elastic-agent run -e &
    AGENT_PID=$!
else
    echo "WARNING: FLEET_URL or ENROLLMENT_TOKEN not provided. Running sleep loop instead."
fi

# Trap signals for clean exit
trap 'kill $AGENT_PID; exit 0' SIGTERM SIGINT

# Keep container running
wait
