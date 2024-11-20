#!/bin/bash

# Function to list active network interfaces and let the user choose
get_active_network_interfaces() {
  echo "Listing active network interfaces..."
  ip -o addr show up | awk '/inet/ {print $2, $4}' | while read -r iface ip; do
    if [[ "$iface" != "lo" ]]; then
      echo "$iface ($ip)"
    fi
  done
}

# Function to get the IP of a given network interface
get_interface_ip() {
  local iface=$1
  echo "Getting IP for interface $iface..."
  ip -o -4 addr show "$iface" | awk '{print $4}' | cut -d'/' -f1
}

# Function to determine if the interface uses static IP configuration
detect_static_ip() {
  local iface=$1
  echo "Detecting IP configuration for interface $iface..."
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
  local ServerIP
  local current_hostname
  local new_hostname

  echo "Setting up network configuration..."
  active_adapters=$(get_active_network_interfaces)
  echo "Active adapters: $active_adapters"

  echo "Please choose a network adapter from the list above:"
  read -r chosen_adapter

  ServerIP=$(get_interface_ip "$chosen_adapter")

  current_hostname=$(hostname)
  echo "Current hostname is $current_hostname. Press Enter to keep it or 'N' to set a new hostname (10 seconds to auto-confirm):"
  read -t 10 -n 1 -r user_input

  if [[ $user_input == "N" || $user_input == "n" ]]; then
    echo "Enter new hostname:"
    read -r new_hostname
    hostnamectl set-hostname "$new_hostname"
    hostname=$new_hostname
  else
    hostname=$current_hostname
  fi

  echo "Configuration will use $ServerIP for program setup where applicable"
  echo "Hostname is set to $hostname"
}

network_setup
