#!/bin/bash

post_install_updates() {
  echo "Performing post-install updates..."
  apt update && apt upgrade -y && apt dist-upgrade -y && flatpak update -y && snap refresh
  if [[ $? -ne 0 ]]; then
    echo "Failed to perform post-install updates." >&2
    exit 1
  fi
}

improve_performance() {
  echo "Configuring swappiness..."
  sysctl vm.swappiness=10
  if ! sysctl -p; then
    echo "Failed to configure swappiness." >&2
    exit 1
  fi
}

configure_routine_maintenance() {
  echo "Setting up weekly updates..."
  cat <<EOF > /etc/cron.d/weekly-updates
# Perform system updates every Sunday at 2:00 AM
0 2 * * 0 root apt update && apt upgrade -y && apt dist-upgrade -y && flatpak update -y && snap refresh
EOF

  echo "Configuring unattended-upgrades for automatic security updates..."
  cat <<EOL > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOL

  sed -i 's|^//.*"${distro_id}:${distro_codename}-security";|"${distro_id}:${distro_codename}-security";|g' /etc/apt/apt.conf.d/50unattended-upgrades

  if systemctl restart unattended-upgrades; then
    echo "Unattended-upgrades configured successfully."
  else
    echo "Failed to configure unattended-upgrades." >&2
    exit 1
  fi
}

post_install_updates
improve_performance
configure_routine_maintenance
