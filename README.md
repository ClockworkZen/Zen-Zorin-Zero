# Zen-Zorin-Zero
Custom configuration file for setting up Zorin OS 17+ as a personal cloud


## What is it?

This is a goofy pet project that might develop into something later.

I don't actually play Zenless Zone Zero, but I like aliteration, so my project is named thusly:

* Zen - That's me! ClockworkZen!
* Zorin - That's what this project is designed to run on, [Zorin OS](https://zorin.com/os/ "Zorin OS"), which is a pretty neat and approachable flavor of Linux built on Ubuntu.
* Zero- Uhhhh... Zero configuration, maybe? 

As this project develops, this may be less true, but for now I plan to make any recommended/default customizations clearly identifiable for customization purposes, and possibly an eventual deployment wizard to make things even easier for non-techies to get going.

## What does it do?

This "tool" is designed to ultra streamline and simplify the process of setting up several useful home server apps in a linux environment, specifically Zorin OS 17+

At this point in time, the script is tailor made for Zorin OS 17, requiring relatively few install pre-requisites that are covered in the install script itself.

Running the script will pull the latest version of the following software from public repos availible:

* Sonarr
* Radarr
* Lidarr
* Prowlarr
* qBittorrent
* SABnzbd
* Rustdusk-Server
* Plex Media Server
* Obsidian
* NextCloud

## And what do those do?


### Usenet/Torrent Software, for Media downloading

### [Sonarr](https://sonarr.tv/)
Sonarr is a smart PVR (Personal Video Recorder) for managing TV shows. It can monitor, download, and organize episodes from various sources, ensuring your collection is always up-to-date.

### [Radarr](https://radarr.video/)
Radarr is a movie collection manager for enthusiasts. It automates the search, download, and organization of movies, tailored to your preferences.

### [Lidarr](https://lidarr.audio/)
Lidarr is a music collection manager that helps you monitor and automatically download albums or tracks from your favorite artists as they are released.

### [Prowlarr](https://prowlarr.com/)
Prowlarr serves as an indexer manager and integrates with your favorite downloaders (Sonarr, Radarr, and Lidarr). It simplifies the process of connecting and syncing multiple indexers.

### [SABnzbd](https://sabnzbd.org/)
SABnzbd is an open-source Usenet downloader that automates the process of downloading, verifying, and unpacking files from Usenet servers.

### [qBittorrent](https://www.qbittorrent.org/)
qBittorrent is a lightweight and powerful BitTorrent client. It features an easy-to-use interface, built-in search, and advanced download management.

---

### Remote Desktop Control

### [Rustdesk-Server](https://rustdesk.com/)
Rustdesk-Server provides a self-hosted option for the Rustdesk remote desktop tool, allowing secure and private remote access to your devices.

---

### Media Streaming and Library

### [Plex Media Server](https://www.plex.tv/)
Plex Media Server organizes and streams your media collection (movies, TV shows, music, photos) to any device. It’s your own personal Netflix for managing and sharing content.

---

### Personal Knowledge Management

### [Obsidian](https://obsidian.md/)
Obsidian is a powerful markdown-based knowledge management app. It's ideal for organizing notes, building personal wikis, and creating interlinked documents.

---

### Personal Cloud

### [NextCloud](https://nextcloud.com/)
NextCloud is a private cloud storage solution that lets you store, access, and share files securely. It's an excellent alternative to services like Google Drive or Dropbox, offering full control of your data.

---

Please check out each tool's original website to learn more about them!

## How to use ZZZ (script form)

How to Run the Script, in terminal
1.	Save the script from GitHub, using your browser or Git solution of choice. This can be saved and run anywhere executable scripts can exist on your install.
2.  Open the Terminal to where your script is saved. Assuming you're using the Zorin OS GUI, you can right click "Open in Terminal" to launch an instance of Terminal set to the current folder's path.
3.	Make the script executable:
```
chmod +x install_apps.sh
```
4.	Run the script, with superuser permissions:
```
sudo ./install_apps.sh
```




## First Run Commands & Interface URLs

- **Sonarr**: `http://localhost:8989`
- **Radarr**: `http://localhost:7878`
- **Lidarr**: `http://localhost:8686`
- **Prowlarr**: `http://localhost:9696`
- **qBittorrent**: `http://localhost:8080`
  - Default username: `admin`
  - Default password: `adminadmin`
- **SABnzbd**: `http://localhost:8085`
- **Rustdesk-Server**:
  - Start commands: `hbbr` and `hbbd`
- **Plex Media Server**: `http://localhost:32400/web`
- **Obsidian**:
  - Launch using: `flatpak run md.obsidian.Obsidian`
- **NextCloud**:
  - Access: `http://localhost` or your server's IP address in a browser.
  - First-time setup:
    1. When you first access the interface, create an admin account by entering a username and password.
    2. Choose a data folder for file storage (default is pre-configured by the Snap installation).
    3. Configure external storage or additional apps if needed via the NextCloud interface.

Check back for more updates!

