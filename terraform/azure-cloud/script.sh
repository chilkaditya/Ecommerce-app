#!/bin/bash

set -e

# Install dependencies
sudo apt update

# Create working directory
mkdir myagent && cd myagent

# Download and extract Azure DevOps agent
wget https://download.agent.dev.azure.com/agent/4.258.1/vsts-agent-linux-x64-4.258.1.tar.gz
tar zxvf vsts-agent-linux-x64-4.258.1.tar.gz

# Configure the agent (environment variables passed in Terraform)
./config.sh --unattended \
  --acceptTeeEula \
  --url "$AZDO_ORG_URL" \
  --auth pat \
  --token "$AZDO_PAT" \
  --pool "$AZDO_POOL" \
  --agent "$(hostname)"

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
  echo "Docker not found, installing..."
  sudo apt install -y docker.io
else
  echo "Docker is already installed."
fi
sudo usermod -aG docker azureuser
sudo systemctl restart docker

# Start the agent
./run.sh
