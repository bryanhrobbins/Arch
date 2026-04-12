#!/bin/bash
source ./install.conf

echo "--- Partitioning & Formatting ---"
sgdisk -Z $DRIVE
sgdisk -n 1:0:+1G -t 1:ef00 $DRIVE
sgdisk -n 2:0:0   -t 2:8300 $DRIVE
mkfs.fat -F 32 "${DRIVE}p1"
mkfs.btrfs -L ARCH "${DRIVE}p2" -f

mount "${DRIVE}p2" /mnt
for sv in "${SUBVOLS[@]}"; do
    IFS=":" read -r name path <<< "$sv"
    btrfs subvolume create "/mnt/$name"
done
umount /mnt

echo "--- Mounting ---"
mount -o compress=zstd,ssd,discard=async,subvol=@ "${DRIVE}p2" /mnt
mkdir -p /mnt/{efi,home,var/log,.snapshots,boot}
mount "${DRIVE}p1" /mnt/efi
mkdir -p /mnt/efi/EFI/archlinux
mount --bind /mnt/efi/EFI/archlinux /mnt/boot
mount -o compress=zstd,ssd,discard=async,subvol=@home "${DRIVE}p2" /mnt/home
mount -o compress=zstd,ssd,discard=async,subvol=@var_log "${DRIVE}p2" /mnt/var/log
mount -o compress=zstd,ssd,discard=async,subvol=@snapshots "${DRIVE}p2" /mnt/.snapshots

echo "--- Base Install & Source Deploy ---"
pacstrap -K /mnt "${PKGS[@]}"
genfstab -U /mnt >> /mnt/etc/fstab
chmod +x ./src/etc/skel/first-run.sh
chmod +x ./src/etc/skel/check-setup.sh
cp -rv ./src/* /mnt/

sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' /mnt/etc/default/useradd

arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "$HOSTNAME" > /etc/hostname
echo "EDITOR=vi" >> /etc/environment
chsh -s /usr/bin/zsh root
useradd -m -G wheel -c "$FULLNAME" $USERNAME
echo "Set password for $USERNAME:"
passwd $USERNAME
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
systemctl enable NetworkManager
systemctl enable iwd
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT="quiet rw mem_sleep_default=s2idle rootflags=subvol=@"|' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
EOF
