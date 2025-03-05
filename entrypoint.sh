#!/bin/bash

echo "############################ entrypoint.sh START ############################"

# Check the container's IP address and network connection
echo "##########################"
echo "Fetching container IP address..."
CONTAINER_IP=$(hostname -I | awk '{print $1}')
echo "Container IP address: $CONTAINER_IP"

# Check if the container can reach a common external address (e.g., Google's DNS server)
echo "Testing network connection..."
ping -c 4 8.8.8.8 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Network connection is working!"
else
    echo "Network connection failed!"
    exit 1
fi

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
