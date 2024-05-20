#!/bin/bash

#nutraukia scriptą betkuriai komandai pasibaigus nenuliniu rezultatu
set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root (sudo)." >&2;
    exit 1;
fi

#surinkti reikalingus duomenis 
DEFAULT_SERVICE_ID="datacollector"

read -rp "Enter service ID for datacollector ($DEFAULT_SERVICE_ID):" SERVICE_ID

read -rp "Enter datacollector push token:" PUSH_TOKEN
if [[ -z "$PUSH_TOKEN" ]]; then
    echo "Push token is required"
    exit 1
fi

read -rp "Enter datahub token:" DATAHUB_TOKEN
if [[ -z "$DATAHUB_TOKEN" ]]; then
    echo "Datahub token not set"
fi

DEFAULT_EASAS_ADDRESS="https://easas.energyadvice.lt/EASAS/rest"

read -rp "Enter used easas addres ($DEFAULT_EASAS_ADDRESS):" EASAS_ADDRESS


#-----------------------------------------------------------------------------------------------------------------------


#Update the apt package index and install packages to allow apt to use a repository over HTTPS:
apt update
apt install ca-certificates curl gnupg -y

#Add Docker’s official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

#Use the following command to set up the repository:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update


#Install Docker Engine, containerd, and Docker Compose.
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

if ! docker run --rm hello-world ; then
    exit 1
fi


#-----------------------------------------------------------------------------------------------------------------------


#create datahub dir
cd /opt
mkdir datahub
cd datahub


git clone https://github.com/energy-advice/datacollector-template.git ./

# datacollector.properties ---SERVICE_ID_NOT_SET---
# datacollector.properties ---TOKEN_NOT_SET---
# datacollector.properties lt.energyadvice.datacollector.remoteServiceUrl
# .env ---DATAHUB_TOKENAS---

sed -i "s/---SERVICE_ID_NOT_SET---/${SERVICE_ID:-$DEFAULT_SERVICE_ID}/" datacollector.properties
sed -i "s/---TOKEN_NOT_SET---/${PUSH_TOKEN}/" datacollector.properties
if [[ -n "$EASAS_ADDRESS" ]]; then
  sed -i "s|#lt.energyadvice.datacollector.remoteServiceUrl=$DEFAULT_EASAS_ADDRESS|lt.energyadvice.datacollector.remoteServiceUrl=$EASAS_ADDRESS|" datacollector.properties
fi

if [[ -n "$DATAHUB_TOKEN" ]]; then
    sed -i "s/---DATAHUB_TOKENAS---/${DATAHUB_TOKEN}/" .env
fi



REALUSER="${SUDO_USER:-$USER}"
chown "$REALUSER:$REALUSER" ./*


#-----------------------------------------------------------------------------------------------------------------------

docker compose pull

set +e

read -rp "Setup docker for access without sudo? (y/N) " choice
choice="${choice:-N}"  # Set default value to "Y" if empty

if [[ $choice =~ ^[Yy]$ ]]; then
    groupadd docker
    usermod -aG docker "$USER"
    newgrp docker
fi


read -rp "Installation complete, start datahub? (Y/n) " choice
choice="${choice:-Y}"  # Set default value to "Y" if empty

if [[ $choice =~ ^[Yy]$ ]]; then
    docker compose up -d
fi

