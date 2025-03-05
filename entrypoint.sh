#!/bin/bash

# Install any extra software defined in the EXTRA_SOFTWARE environment variable
if [ -n "$EXTRA_SOFTWARE" ]; then
    echo "Installing the following packages: $EXTRA_SOFTWARE"
    apt-get update && apt-get install -y $(echo $EXTRA_SOFTWARE | tr " " "\n")
fi
    
# Execute the PowerShell script from the mounted /scripts directory
pwsh -File /scripts/DockerTest.ps1

# Exit the container when done
exit 0
