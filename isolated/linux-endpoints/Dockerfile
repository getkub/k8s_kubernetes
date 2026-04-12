FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    rsyslog \
    cron \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Add a test user for simulating brute-force
RUN useradd -rm -d /home/testuser -s /bin/bash -g root -G sudo testuser && \
    echo 'testuser:testpassword' | chpasswd

RUN mkdir /var/run/sshd

# Ensure we have the right arch for elastic agent
ARG TARGETARCH
ENV ELASTIC_VERSION=8.17.0
RUN if [ "$TARGETARCH" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then \
      AGENT_ARCH="arm64"; \
    else \
      AGENT_ARCH="x86_64"; \
    fi && \
    curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-${ELASTIC_VERSION}-linux-${AGENT_ARCH}.tar.gz && \
    tar xzvf elastic-agent-${ELASTIC_VERSION}-linux-${AGENT_ARCH}.tar.gz && \
    mv elastic-agent-${ELASTIC_VERSION}-linux-${AGENT_ARCH} /opt/elastic-agent && \
    rm elastic-agent-${ELASTIC_VERSION}-linux-${AGENT_ARCH}.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Will be mounted by Helm
# RUN mkdir -p /etc/elastic-agent

ENTRYPOINT ["/entrypoint.sh"]
