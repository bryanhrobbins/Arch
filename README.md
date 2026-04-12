# 🚀 Arch Linux Dell 15 (7320U)

## 🛠 Key Architecture
- **Filesystem:** Btrfs + Subvolumes (`@`, `@home`, `@var_log`, `@snapshots`).
- **Persistence:** Snapper + `grub-btrfs` + `snapper-rollback`.
- **Shell:** Zsh with XDG Enforcement.
- **Boot:** `systemd` hooks + Terminus font.

## 💾 Installation
1. Boot Arch ISO, connect to Wi-Fi.
2. Clone: `git clone https://github.com/bryanhrobbins/Arch.git`
3. Run: `./install.sh`
4. Reboot, Login, and Run: `./first-run.sh`
