#!/bin/bash

# Ensure the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

########################
# Script Config Section
########################

# Function to get the primary IP address (prioritizing Ethernet)
get_primary_ip() {
  local primary_ip=""
  
  # Try to get the Ethernet IP first
  primary_ip=$(ip addr show eth0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
  
  # If no Ethernet IP, try WiFi
  if [ -z "$primary_ip" ]; then
    primary_ip=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
  fi
  
  echo "$primary_ip"
}

# Check if the current IP is statically configured
detect_static_ip() {
  local iface=$1
  grep -q "iface $iface inet static" /etc/network/interfaces 2>/dev/null
}

# Function to validate and set ServIP
validate_and_set_ip() {
  # Get primary network interface (prefer Ethernet, fallback to WiFi)
  primary_iface=""
  if ip link show eth0 &>/dev/null; then
    primary_iface="eth0"
  elif ip link show wlan0 &>/dev/null; then
    primary_iface="wlan0"
  else
    echo "No suitable network interface found." >&2
    exit 1
  fi

  # Check if the IP is statically configured
  if detect_static_ip "$primary_iface"; then
    ServIP=$(get_primary_ip)
    echo "Static IP detected: $ServIP"
  else
    # Get current IP address (DHCP assigned)
    current_ip=$(get_primary_ip)
    if [ -z "$current_ip" ]; then
      echo "No IP address assigned to $primary_iface." >&2
      exit 1
    fi
    
    # Prompt the user for confirmation
    echo "Current IP address (DHCP assigned) is: $current_ip"
    echo -n "Do you want to proceed with this IP as ServIP? [Y/n] (default is Y): "
    read -t 10 user_response
    user_response=${user_response:-Y}

    # Handle user response
    if [[ "$user_response" =~ ^([nN])$ ]]; then
      echo "Aborting IP configuration." >&2
      exit 1
    else
      ServIP="$current_ip"
    fi
  fi

  # ServIP is now set and can be used for later configuration tasks
  echo "ServIP has been set to: $ServIP"
}

########################
# Fresh OS Prep Section
########################

# Function to perform system updates and preparations
fresh_os_prep() {
  echo "Starting post-installation setup..."
  echo "Updating the system..."
  if ! apt update && apt upgrade -y && apt dist-upgrade -y; then
    echo "System update failed." >&2
    exit 1
  fi

  echo "Installing common tools..."
  if ! apt install -y curl htop tmux build-essential flatpak snapd logrotate unattended-upgrades; then
    echo "Failed to install common tools." >&2
    exit 1
  fi

  echo "Updating flatpak and snap packages..."
  if ! flatpak update -y || ! snap refresh; then
    echo "Failed to update flatpak or snap packages." >&2
    exit 1
  fi

  echo "Configuring logrotate to keep logs for 30 days..."
  cat <<EOF > /etc/logrotate.conf
# see "man logrotate" for details
# rotate log files weekly
weekly
# keep 4 weeks worth of backlogs
rotate 4
# create new (empty) log files after rotating old ones
create
# use the syslog group by default, since this is the owning group
# of /var/log/syslog.
su root syslog
# include all logrotate files in /etc/logrotate.d
include /etc/logrotate.d
# no packages own wtmp and btmp -- we'll rotate them here
/var/log/wtmp {
    monthly
    create 0664 root utmp
    rotate 1
}
/var/log/btmp {
    monthly
    create 0660 root utmp
    rotate 1
}
# system-specific logs may be also be configured here.
EOF

  echo "Logrotate configuration updated."

  echo "Configuring swappiness to reduce swap usage..."
  echo "vm.swappiness=10" >> /etc/sysctl.conf
  if ! sysctl -p; then
    echo "Failed to configure swappiness." >&2
    exit 1
  fi

  echo "Setting up weekly updates..."
  cat <<EOF > /etc/cron.d/weekly-updates
# Perform system updates every Sunday at 2:00 AM
0 2 * * 0 root apt update && apt upgrade -y && apt dist-upgrade -y && flatpak update -y && snap refresh
EOF

  echo "Configuring unattended-upgrades for automatic security updates..."
  if ! dpkg-reconfigure --priority=low unattended-upgrades; then
    echo "Failed to configure unattended-upgrades." >&2
    exit 1
  fi

  echo "Cleaning up..."
  if ! apt autoremove -y || ! apt autoclean -y; then
    echo "Cleanup failed." >&2
    exit 1
  fi

  echo "Post-installation setup completed!"
}

########################
# Main Script Execution
########################

echo "Running Script Config..."
validate_and_set_ip

echo "Running Fresh OS Prep..."
fresh_os_prep

# Exit notification
echo "Script completed successfully!"
