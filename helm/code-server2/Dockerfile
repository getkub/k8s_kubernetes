FROM codercom/code-server

# Add Ansible and good tools
RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y \
  jq \
  unzip \
  libarchive-tools \
  wget && \
  echo "**** install ansible ****" && \
  apt-get install -y software-properties-common && \
  add-apt-repository --yes --update ppa:ansible/ansible && \
  apt-get install -y ansible && \
  && sudo rm -rf /var/lib/apt/lists/*
