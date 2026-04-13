#!/usr/bin/env zsh
# Run this once after first boot
{
    echo "--- AUR & Snapshot Finalization ---"
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
    
    sudo systemctl enable --now grub-btrfsd.service snapper-timeline.timer snapper-cleanup.timer
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    ~/check-setup.sh
} 2>&1 | sudo tee -a "/var/log/first-run.log"
