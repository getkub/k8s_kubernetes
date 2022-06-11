FROM codercom/code-server

# Add Ansible and good tools
RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y \
  jq \
  git \
  unzip \
  libarchive-tools \
  wget && \
  echo "**** install ansible ****" && \
  sudo apt-get install -y software-properties-common && \
  sudo add-apt-repository --yes --update ppa:ansible/ansible && \
  sudo apt-get install -y ansible && \
  sudo rm -r /var/lib/apt/lists/*
