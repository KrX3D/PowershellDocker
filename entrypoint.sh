#!/bin/bash

# Check if apt-get is available
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

# Execute the PowerShell script from the mounted /scripts directory
echo "Executing PowerShell script..."
pwsh -File /scripts/DockerTest.ps1

# Exit the container when done
echo "Exiting the container."
exit 0
