#!/bin/bash
source ./install.conf

echo "--- Partitioning $DRIVE (1GiB EFI) ---"
sgdisk -Z $DRIVE
sgdisk -n 1:0:+1G   -t 1:ef00 $DRIVE
sgdisk -n 2:0:0     -t 2:8300 $DRIVE

echo "--- Formatting & Btrfs Setup ---"
mkfs.fat -F 32 "${DRIVE}p1"
mkfs.btrfs -L ARCH "${DRIVE}p2" -f

mount "${DRIVE}p2" /mnt
for sv in "${SUBVOLS[@]}"; do
    IFS=":" read -r name path <<< "$sv"
    btrfs subvolume create "/mnt/$name"
done
umount /mnt

echo "--- Mounting Hierarchy ---"
mount -o compress=zstd,ssd,discard=async,subvol=@ "${DRIVE}p2" /mnt
mkdir -p /mnt/{efi,home,var/log,.snapshots,boot}
mount "${DRIVE}p1" /mnt/efi
mkdir -p /mnt/efi/EFI/archlinux
mount --bind /mnt/efi/EFI/archlinux /mnt/boot
mount -o compress=zstd,ssd,discard=async,subvol=@home "${DRIVE}p2" /mnt/home
mount -o compress=zstd,ssd,discard=async,subvol=@var_log "${DRIVE}p2" /mnt/var/log
mount -o compress=zstd,ssd,discard=async,subvol=@snapshots "${DRIVE}p2" /mnt/.snapshots

echo "--- Installing Packages ---"
pacstrap -K /mnt "${PKGS[@]}"

echo "--- Generating Fstab ---"
genfstab -U /mnt >> /mnt/etc/fstab

echo "--- Configuring systemd & zram ---"
sed -i 's/^HOOKS=(.*)/HOOKS=(systemd autodetect modconf kms sd-vconsole block filesystems btrfs)/' /mnt/etc/mkinitcpio.conf

cat <<zramEOF > /mnt/etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
zramEOF

echo "--- Entering Chroot ---"
arch-chroot /mnt /bin/bash <<EOF
# Localization & System
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "$HOSTNAME" > /etc/hostname
echo "EDITOR=vi" >> /etc/environment
echo "VISUAL=vi" >> /etc/environment

# User & Sudo
useradd -m -G wheel -s /bin/bash -c "$FULLNAME" $USERNAME
echo "Set password for $USERNAME:"
passwd $USERNAME
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Networking
systemctl enable NetworkManager

# Initramfs & Bootloader
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="quiet rw mem_sleep_default=s2idle rootflags=subvol=@"|' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
EOF

echo "Installation complete! The system is ready for reboot."
