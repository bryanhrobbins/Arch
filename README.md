# 🚀 Arch Linux Dell 15 (7320U) - SysAdmin Build

This is a public deployment script for a professional Arch Linux workstation.

## ⚠️ PRE-INSTALLATION STEP
This repository uses a **dummy** `install.conf`. You **MUST** edit it before running the installer, or the installation will fail or use default "dummy" credentials.

### 💾 Installation Flow
1. **Boot** Arch ISO and connect to Wi-Fi.
2. **Clone**: `git clone https://github.com/bryanhrobbins/Arch.git && cd Arch`
3. **Configure**: `nano install.conf` <-- **Change passwords and username here!**
4. **Deploy**: `chmod +x install.sh && ./install.sh`
5. **Finalize**: Reboot, login, and run `./first-run.sh`
