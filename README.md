# Arch Linux - Dell 15 (AMD 7320U)

This system is configured with a minimal Arch Linux base utilizing **Btrfs** and **systemd** hooks.

## System Specifications
- **Hardware:** Dell 15 dc15255
- **CPU:** AMD Ryzen 3 7320U (Mendocino)
- **Power Management:** s2idle (Modern Standby)
- **Storage:** NVMe with Btrfs Subvolumes
- **Swap:** zram (zstd compressed)

## Partitioning & Layout
| Mount Point | Device/Subvolume | Options |
| :--- | :--- | :--- |
| `/efi` | `/dev/nvme0n1p1` | 1GiB FAT32 |
| `/boot` | `/efi/EFI/archlinux` | Bind Mount |
| `/` | `subvol=@` | zstd, ssd, discard=async |
| `/home` | `subvol=@home` | zstd, ssd, discard=async |
| `/var/log` | `subvol=@var_log` | zstd, ssd, discard=async |
| `/.snapshots` | `subvol=@snapshots` | zstd, ssd, discard=async |

## Post-Install Checklist
1. **Connect to Wi-Fi:** `nmcli device wifi connect SSID password PASSWORD`
2. **Setup Snapshots:** Install `snapper` and `snap-pac`.
3. **Clean Cache:** `sudo systemctl enable --now paccache.timer`
4. **Git Init:** ```bash
   git init
   git config --global user.name "John Doe"
   git config --global user.email "jdoe@arch-dell"
   git add README.md
   git commit -m "Initial commit"
