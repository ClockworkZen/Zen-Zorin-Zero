#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Execute scripts
echo "Running Network Setup..."
source ./setup.sh

echo "Running Environment Tuning..."
source ./environment_tuning.sh

echo "Running Post-Run Cleanup..."
source ./post_run_tasks.sh

# Exit notification
echo "Script completed successfully!"
