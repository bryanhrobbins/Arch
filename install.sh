#!/bin/bash
source ./install.conf

# Log to the persistent subvolume
LOG_FILE="/mnt/var/log/install.log"

{
    echo "--- Installation Started: $(date) ---"

    # 1. Partitioning
    sgdisk -Z $DRIVE
    sgdisk -n 1:0:+1G -t 1:ef00 $DRIVE
    sgdisk -n 2:0:0   -t 2:8300 $DRIVE
    mkfs.fat -F 32 "${DRIVE}p1"
    mkfs.btrfs -L ARCH "${DRIVE}p2" -f

    # 2. Btrfs Layout
    mount "${DRIVE}p2" /mnt
    for sv in "${SUBVOLS[@]}"; do
        IFS=":" read -r name path <<< "$sv"
        btrfs subvolume create "/mnt/$name"
    done
    umount /mnt

    # 3. Mounting
    mount -o compress=zstd,ssd,discard=async,subvol=@ "${DRIVE}p2" /mnt
    mkdir -p /mnt/{efi,home,var/log,.snapshots,boot}
    mount "${DRIVE}p1" /mnt/efi
    mount --bind /mnt/efi/EFI/archlinux /mnt/boot
    mount -o compress=zstd,ssd,discard=async,subvol=@home "${DRIVE}p2" /mnt/home
    mount -o compress=zstd,ssd,discard=async,subvol=@var_log "${DRIVE}p2" /mnt/var/log
    mount -o compress=zstd,ssd,discard=async,subvol=@snapshots "${DRIVE}p2" /mnt/.snapshots

    # 4. Installation
    pacstrap -K /mnt "${PKGS[@]}"
    genfstab -U /mnt >> /mnt/etc/fstab
    cp -rv ./src/* /mnt/

    # 5. Configuration (Chroot)
    arch-chroot /mnt /bin/bash <<EOF
        ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
        hwclock --systohc
        echo "$LOCALE UTF-8" >> /etc/locale.gen
        locale-gen
        echo "LANG=$LOCALE" > /etc/locale.conf
        echo "$HOSTNAME" > /etc/hostname

        # Networking
        systemctl enable NetworkManager iwd
        printf "[device]\nwifi.backend=iwd\n" > /etc/NetworkManager/conf.d/wifi_backend.conf
        
        # UI/UX Tweaks
        sed -i 's|^# include "/usr/share/nano/\*.nanorc"|include "/usr/share/nano/*.nanorc"|' /etc/nanorc

        # User & Security
        useradd -m -G wheel -s /usr/bin/zsh -c "$FULLNAME" $USERNAME
        echo "root:$ROOT_PASS" | chpasswd
        echo "$USERNAME:$USER_PASS" | chpasswd
        passwd -u root
        passwd -u $USERNAME
        sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

        # Init & Boot
        sed -i 's/^HOOKS=(.*/HOOKS=(systemd autodetect modconf kms keyboard sd-vconsole block filesystems fsck)/' /etc/mkinitcpio.conf
        mkinitcpio -P
        grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
        sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="quiet rw mem_sleep_default=s2idle rootflags=subvol=@"|' /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
EOF

    echo "--- Installation Finished: $(date) ---"
} 2>&1 | tee -a "$LOG_FILE"
