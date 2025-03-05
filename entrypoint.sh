#!/bin/bash

echo "############################ entrypoint.sh START ############################"

########################################################### Install Software
# Check if apt-get is available
echo "##########################"
echo "Checking if apt-get is available..."
if command -v apt-get &>/dev/null; then
    echo "apt-get is installed and available."
else
    echo "apt-get is not installed. Exiting..."
    exit 1
fi

# Install any extra software defined in the EXTRA_SOFTWARE environment variable
if [ -n "$EXTRA_SOFTWARE" ]; then
    # Remove any extra quotes from the package names
    EXTRA_SOFTWARE=$(echo $EXTRA_SOFTWARE | tr -d '"')
    
    echo "##########################"
    echo "Installing the following packages: $EXTRA_SOFTWARE"

    # Ensure package repositories are up-to-date
    echo "Updating package lists with apt-get update..."
    apt-get update
    if [ $? -ne 0 ]; then
        echo "apt-get update failed. Exiting..."
        exit 1
    else
        echo "apt-get update successful."
    fi

    # Install the packages listed in EXTRA_SOFTWARE
    for package in $(echo $EXTRA_SOFTWARE | tr " " "\n"); do
        echo "Attempting to install package: $package"
        
        # Try installing the package
        apt-get install -y $package
        if [ $? -ne 0 ]; then
            echo "Failed to install package: $package"
        else
            echo "Successfully installed package: $package"
        fi
    done
else
    echo "No extra software specified in the EXTRA_SOFTWARE environment variable."
fi

############################# Test Network

# Check the container's IP address and network connection
echo "##########################"
echo "Fetching container IP address..."
CONTAINER_IP=$(hostname -I | awk '{print $1}')
echo "Container IP address: $CONTAINER_IP"

# Install iproute2 if not present
if ! command -v ip &>/dev/null; then
    echo "ip command not found. Installing iproute2..."
    apt-get update && apt-get install -y iproute2
fi

# Check the container's routing table
echo "##########################"
echo "Fetching routing table..."
ip route

# Check if the container can reach the gateway
GATEWAY_IP=$(ip route | grep default | awk '{print $3}')
echo "Testing connection to the gateway ($GATEWAY_IP)..."
ping -c 4 $GATEWAY_IP > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Gateway ($GATEWAY_IP) is reachable."
else
    echo "Gateway ($GATEWAY_IP) is not reachable."
fi

# Test if the container can reach an external IP (e.g., Google's DNS server)
echo "Testing network connection to external IP (8.8.8.8)..."
ping -c 4 8.8.8.8 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Network connection to 8.8.8.8 is working!"
else
    echo "Network connection to 8.8.8.8 failed!"
fi


# Test DNS resolution (e.g., google.com)
echo "Testing DNS resolution for google.com..."
ping -c 4 google.com > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "DNS resolution is working!"
else
    echo "DNS resolution failed!"
    echo "Checking DNS configuration in /etc/resolv.conf"
    cat /etc/resolv.conf
    echo "You may need to configure DNS manually."

    # Manually set the DNS server to your custom one
    echo "nameserver 192.168.90.220" > /etc/resolv.conf
    echo "DNS configured to 192.168.90.220."
    
    # Retry DNS resolution after manual update
    ping -c 4 google.com > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "DNS resolution after manual update is working!"
    else
        echo "DNS resolution after manual update still failed!"
    fi
fi

####################### 
# Check the contents of /scripts and verify DockerDefault.ps1
echo "##########################"
echo "Listing all files in /scripts directory:"
ls -alh /scripts/

# Check if a specific PowerShell script file is provided, else use DockerDefault.ps1
if [ -n "$SCRIPT_FILE" ]; then
    # Remove any quotes around SCRIPT_FILE variable
    SCRIPT_FILE=$(echo $SCRIPT_FILE | tr -d '"')
    
    echo "##########################"
    echo "Executing PowerShell script: $SCRIPT_FILE"
    pwsh -File /scripts/$SCRIPT_FILE
else
    echo "##########################"
    echo "No script specified. Executing default script: DockerDefault.ps1"
    
    # Check if DockerDefault.ps1 exists
    echo "Checking if DockerDefault.ps1 exists..."
    if [ -f /DockerDefault.ps1 ]; then
        echo "DockerDefault.ps1 exists."
    else
        echo "DockerDefault.ps1 not found."
    fi
    
    pwsh -File /DockerDefault.ps1
fi

# Exit the container when done
echo "Exiting the container."
echo "############################ entrypoint.sh END ############################"
exit 0
