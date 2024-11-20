#!/bin/bash

# Ensure the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

########################
# Script Config Section
########################

# Function to list active network interfaces and let the user choose
get_active_network_interfaces() {
  ip -o addr show up | awk '/inet/ {print $2, $4}' | while read -r iface ip; do
    echo "$iface ($ip)"
  done
}

# Function to get the IP of a given network interface
get_interface_ip() {
  local iface=$1
  ip -o -4 addr show "$iface" | awk '{print $4}' | cut -d'/' -f1
}

# Function to determine if the interface uses static IP configuration
detect_static_ip() {
  local iface=$1
  if grep -q "iface $iface inet static" /etc/network/interfaces 2>/dev/null; then
    echo "Static"
  elif grep -q "$iface.*dhcp" /etc/NetworkManager/system-connections/* 2>/dev/null; then
    echo "DHCP"
  else
    echo "Unknown"
  fi
}

# Main function to detect network adapter and handle IP configuration
network_setup() {
  local active_adapters
  local chosen_adapter
  local adapter_count

  # Get a list of active network interfaces
  active_adapters=($(get_active_network_interfaces))
  adapter_count=${#active_adapters[@]}

  if [ "$adapter_count" -eq 0 ]; then
    echo "No active network interfaces found." >&2
    exit 1
  elif [ "$adapter_count" -eq 1 ]; then
    # Only one active interface
    chosen_adapter=$(echo "${active_adapters[0]}" | awk '{print $1}')
  else
    # Multiple active interfaces
    echo "Multiple active network interfaces found:"
    select iface in "${active_adapters[@]}"; do
      if [ -n "$iface" ]; then
        chosen_adapter=$(echo "$iface" | awk '{print $1}')
        break
      else
        echo "Invalid selection. Please try again."
      fi
    done
  fi

  # Get the IP address of the chosen interface
  ServerIP=$(get_interface_ip "$chosen_adapter")

  if [ -z "$ServerIP" ]; then
    echo "Unable to determine the IP address for $chosen_adapter." >&2
    exit 1
  fi

  # Detect if the IP is statically configured
  ip_config_type=$(detect_static_ip "$chosen_adapter")
  case "$ip_config_type" in
    "Static")
      echo "Manual IP configuration found. Assuming this address to be static."
      ;;
    "DHCP")
      echo "DHCP assigned IP found. Assuming a static route is set on the network routing device."
      ;;
    "Unknown")
      echo "Network adapter state could not be determined. Check your configuration and try again." >&2
      exit 1
      ;;
  esac

  # Output the chosen IP for future use
  echo "ServerIP has been set to: $ServerIP"
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

echo "Running Network Setup..."
network_setup

echo "Running Fresh OS Prep..."
fresh_os_prep

# Exit notification
echo "Script completed successfully!"
