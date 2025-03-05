#!/bin/bash

# Install additional software if specified via the environment variable
if [ -n "$EXTRA_SOFTWARE" ]; then
    apt-get update && apt-get install -y $EXTRA_SOFTWARE
fi

# Execute the PowerShell script from the mounted /scripts directory
pwsh -File /scripts/DockerTest.ps1

# Exit the container when done
exit 0
