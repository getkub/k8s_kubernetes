#!/bin/bash

# Start rsyslog
service rsyslog start

# Start sshd
/usr/sbin/sshd

# Ensure elastic-agent has configuration
# The config map will mount to /etc/agent/elastic-agent.yml
if [ -f "/etc/agent/elastic-agent.yml" ]; then
    echo "Starting Elastic Agent with standalone config..."
    cd /opt/elastic-agent
    ./elastic-agent run -c /etc/agent/elastic-agent.yml -e &
    AGENT_PID=$!
else
    echo "WARNING: /etc/agent/elastic-agent.yml not found. Running sleep loop instead."
fi

# Trap signals for clean exit
trap 'kill $AGENT_PID; exit 0' SIGTERM SIGINT

# Keep container running
wait
