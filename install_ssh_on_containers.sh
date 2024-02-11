#!/bin/bash

# Function to install SSH on Ubuntu container
install_ssh_ubuntu() {
    local container_name=$1

    # Install SSH on the Ubuntu container
    docker exec $container_name apt-get update
    docker exec $container_name apt-get install -y openssh-server
    docker exec $container_name service ssh start

    # Set up SSH to allow root login with keys
    docker exec $container_name mkdir -p /root/.ssh
    docker cp ~/.ssh/id_rsa_docker.pub $container_name:/root/.ssh/authorized_keys
    docker exec $container_name chmod 600 /root/.ssh/authorized_keys
    docker exec $container_name sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    docker exec $container_name service ssh restart
}

# Function to install SSH on RHEL container
install_ssh_rhel() {
    local container_name=$1

    # Install SSH on the RHEL container
    docker exec $container_name yum -y install openssh-server
    docker exec $container_name ssh-keygen -A
    docker exec $container_name systemctl enable sshd
    docker exec $container_name systemctl start sshd

    # Set up SSH to allow root login with keys
    docker exec $container_name mkdir -p /root/.ssh
    docker cp ~/.ssh/id_rsa_docker.pub $container_name:/root/.ssh/authorized_keys
    docker exec $container_name chmod 600 /root/.ssh/authorized_keys
    docker exec $container_name sed -i 's/#PermitRootLogin yes/PermitRootLogin without-password/' /etc/ssh/sshd_config
    docker exec $container_name systemctl restart sshd
}

# Replace with your actual container names
UBUNTU_CONTAINER_NAME="my_ubuntu_container"
RHEL_CONTAINER_NAME="my_rhel_container"

# Generate SSH key pair if it doesn't exist
if [ ! -f ~/.ssh/id_rsa_docker ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_docker -N ""
fi

# Install SSH on the containers
install_ssh_ubuntu $UBUNTU_CONTAINER_NAME
install_ssh_rhel $RHEL_CONTAINER_NAME

echo "SSH has been installed on the containers and configured for key-based authentication."
