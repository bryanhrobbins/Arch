#!/usr/bin/env zsh
echo "--- AUR & Snapper Setup ---"
TEMP_DIR=$(mktemp -d)
git clone https://aur.archlinux.org/paru-bin.git "$TEMP_DIR"
cd "$TEMP_DIR" && makepkg -si --noconfirm
cd - && rm -rf "$TEMP_DIR"
paru -S --noconfirm snapper-rollback

sudo umount /.snapshots
sudo rm -rf /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots
sudo mount -a
sudo chmod 750 /.snapshots

sudo snapper -c root set-config NUMBER_LIMIT=10 NUMBER_LIMIT_IMPORTANT=10 TIMELINE_LIMIT_HOURLY=5 TIMELINE_LIMIT_DAILY=7
sudo systemctl enable --now grub-btrfsd.service snapper-timeline.timer snapper-cleanup.timer
sudo grub-mkconfig -o /boot/grub/grub.cfg

xdg-user-dirs-update
~/check-setup.sh
