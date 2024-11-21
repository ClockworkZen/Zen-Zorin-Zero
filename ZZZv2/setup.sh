#!/bin/bash

# Function to get all active network interfaces excluding loopback and non-IPv4 addresses
get_active_network_interfaces() {
  ip -o -4 addr show | awk '{print $2}' | grep -v '^lo$' | sort -u
}

# Function to get the IP of a given network interface
get_interface_ip() {
  local iface=$1
  ip -o -4 addr show "$iface" | awk '{print $4}' | cut -d'/' -f1
}

# Function to determine if the interface uses static IP configuration
detect_static_ip() {
  local iface=$1

  # Check if the interface is configured as static in /etc/network/interfaces
  if grep -q "iface $iface inet static" /etc/network/interfaces 2>/dev/null; then
    echo "Static"
    return
  fi

  # Check if the interface is configured with DHCP in NetworkManager connections
  if grep -q "interface-name=$iface" /etc/NetworkManager/system-connections/* 2>/dev/null; then
    if grep -q "dhcp" /etc/NetworkManager/system-connections/* 2>/dev/null; then
      echo "DHCP"
      return
    fi
  fi

  # If neither static nor DHCP is found, return Unknown
  echo "Unknown"
}


# Main function to detect network adapter and handle IP configuration
network_setup() {
  local active_adapters
  local chosen_adapter
  local adapter_count
  local ServerIP
  local current_hostname
  local new_hostname
  local DHCP_On

  echo "Setting up network configuration..."
  active_adapters=$(get_active_network_interfaces)
  adapter_count=$(echo "$active_adapters" | wc -l)

  if [ "$adapter_count" -eq 0 ]; then
    echo "No active network interfaces found."
    exit 1
  elif [ "$adapter_count" -eq 1 ]; then
    chosen_adapter=$(echo "$active_adapters")
  else
    echo "Active adapters:"
    echo "$active_adapters" | nl -w 2 -s '. '
    echo "Please choose a network adapter by number:"
    read -r adapter_number
    chosen_adapter=$(echo "$active_adapters" | sed -n "${adapter_number}p")
  fi

  echo "Chosen adapter: $chosen_adapter"
  ServerIP=$(get_interface_ip "$chosen_adapter")
  echo "IP Address: $ServerIP"

  ip_config=$(detect_static_ip "$chosen_adapter")
  if [ "$ip_config" = "DHCP" ]; then
    DHCP_On=true
  else
    DHCP_On=false
  fi

  if [ "$DHCP_On" = true ]; then
    echo "Warning: The chosen adapter is set to DHCP mode."
  else
    echo "Warning: The chosen adapter is set to Static IP mode."
  fi
}

network_setup
