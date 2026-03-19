<h1 align="center">UNIT3D Community Edition Installer</h1>

<p align="center">
    🎉<b>A Big Thanks To All Our <a href="https://github.com/HDInnovations/UNIT3D-Community-Edition/graphs/contributors">Contributors</a> and <a href="https://github.com/sponsors/HDVinnie">Sponsors</a></b>🎉
</p>

<p align="center"><b>NOTE: This only works for a fresh server with nothing on it but a new OS install!</b></p>

## This Repository
Installer for the [UNIT3D-Community-Edition](https://github.com/stivi05/UNIT3D). Optimized for v9.2.0+.

**Officially Supported OS's**
- Ubuntu 24.04 LTS (Noble Numbat) - **Recommended**
- Ubuntu 22.04 LTS (Jammy Jellyfish)

**Technological Stack**
- **PHP:** 8.4
- **Search:** Meilisearch (Integrated)
- **JS Runtime:** Bun
- **Database:** MySQL 8.0+

**We offer install and tuning services for a small price if not comfortable installing and tuning server yourself. Otherwise, if you want to install it yourself, run the commands below.**

**To install run the following:** (and follow the instructions. Must be a fresh dedicated server with nothing on it besides supported OS. Also must have a proper valid domain pointing to your server IP via A RECORD and CNAME for www)

```bash
sudo apt update && sudo apt -y install git
sudo git clone [https://github.com/stivi05/UNIT3D-Installer.git](https://github.com/stivi05/UNIT3D-Installer.git) installer
cd installer
sudo chmod +x install.sh ubuntu.sh artisan
sudo ./install.sh

.env  <-- SESSION_SECURE_COOKIE must be set to false
config/secure-headers.php   <-- HTTP Strict Transport Security must be set to false
config/secure-headers.php   <-- Content Security Policy must be disabled
