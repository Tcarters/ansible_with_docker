#!/bin/bash

# Ansible inventory file
INVENTORY_FILE="hosts"

# Function to retrieve and add container IP to the inventory
add_container_ip_to_inventory() {
    local container_name="$1"
    local inventory_group="$2"

    # Retrieve the IP address of the Docker container
    local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_name")

    # Check if the IP address was successfully retrieved
    if [ -z "$container_ip" ]; then
        echo "Failed to retrieve IP address for container $container_name"
        return 1
    fi

    # Check if the inventory group already exists
    if grep -q "^\[$inventory_group\]" "$INVENTORY_FILE"; then
        # The group exists, append the container IP to the group
        echo "$container_ip" >> "$INVENTORY_FILE"
    else
        # The group doesn't exist, create it and add the container IP
        echo "[$inventory_group]" >> "$INVENTORY_FILE"
        echo "$container_ip" >> "$INVENTORY_FILE"
    fi

    echo "Updated inventory file with $container_name IP: $container_ip"
}

# Add RHEL container IP
add_container_ip_to_inventory "my_rhel_container" "rhel_containers"

# Add Ubuntu container IP
add_container_ip_to_inventory "my_ubuntu_container" "ubuntu_containers"




# #!/bin/bash

# # Name of the Docker container
# CONTAINER_NAME="my_container"

# # Name of the Ansible inventory file
# INVENTORY_FILE="hosts"

# # Retrieve the IP address of the Docker container
# CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME")

# # Check if the IP address was successfully retrieved
# if [ -z "$CONTAINER_IP" ]; then
#     echo "Failed to retrieve IP address for container $CONTAINER_NAME"
#     exit 1
# fi

# # Update the Ansible inventory file with the container's IP address
# # This example assumes you want to add the container under a group called 'docker_containers'
# echo "[docker_containers]" > "$INVENTORY_FILE"
# echo "$CONTAINER_IP" >> "$INVENTORY_FILE"

# echo "Updated inventory file with container IP: $CONTAINER_IP"
