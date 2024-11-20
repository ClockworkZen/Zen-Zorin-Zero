#!/bin/bash

# Update system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install prerequisites
echo "Installing prerequisites..."
sudo apt install -y apt-transport-https curl wget gdebi-core flatpak snapd software-properties-common unzip

# Enable Flatpak support
echo "Adding Flatpak support..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install Sonarr
echo "Installing Sonarr..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
echo "deb https://apt.sonarr.tv/ master main" | sudo tee /etc/apt/sources.list.d/sonarr.list
sudo apt update && sudo apt install -y sonarr
sudo systemctl enable --now sonarr

# Install Radarr
echo "Installing Radarr..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
echo "deb https://apt.radarr.video/ master main" | sudo tee /etc/apt/sources.list.d/radarr.list
sudo apt update && sudo apt install -y radarr
sudo systemctl enable --now radarr

# Install Lidarr
echo "Installing Lidarr..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
echo "deb https://apt.lidarr.audio/ master main" | sudo tee /etc/apt/sources.list.d/lidarr.list
sudo apt update && sudo apt install -y lidarr
sudo systemctl enable --now lidarr

# Install Prowlarr
echo "Installing Prowlarr..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC
echo "deb https://apt.prowlarr.video/ master main" | sudo tee /etc/apt/sources.list.d/prowlarr.list
sudo apt update && sudo apt install -y prowlarr
sudo systemctl enable --now prowlarr

# Install qBittorrent
echo "Installing qBittorrent..."
sudo apt install -y qbittorrent-nox
sudo systemctl enable --now qbittorrent-nox

# Install SABnzbd
echo "Installing SABnzbd..."
sudo add-apt-repository -y ppa:sabnzbd-team/sabnzbd
sudo apt update && sudo apt install -y sabnzbdplus
sudo systemctl enable --now sabnzbdplus

# Install Rustdesk-Server
echo "Installing Rustdesk-Server..."
wget https://github.com/rustdesk/rustdesk-server/releases/latest/download/rustdesk-server-linux-amd64.zip
unzip rustdesk-server-linux-amd64.zip
chmod +x hbbr hbbd
sudo mv hbbr hbbd /usr/local/bin
sudo nohup hbbr &
sudo nohup hbbd &

# Install Plex Media Server
echo "Installing Plex Media Server..."
PLEX_DEB=$(curl -s https://plex.tv/api/downloads/5.json | grep -oP 'https://[^"]+amd64.deb')
wget $PLEX_DEB -O plexmediaserver.deb
sudo dpkg -i plexmediaserver.deb
sudo apt --fix-broken install -y
sudo systemctl enable --now plexmediaserver

# Install Obsidian
echo "Installing Obsidian..."
flatpak install flathub md.obsidian.Obsidian -y

# Install NextCloud
echo "Installing NextCloud..."
sudo snap install nextcloud

# Final message
echo "All applications have been installed successfully!"
