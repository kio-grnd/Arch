#!/bin/bash
# loadkeys es
# cfdisk /dev/sdc
#
# mkswap /dev/sdc1
# mkfs.ext4 /dev/sdc2
# swapon /dev/sdc1
# mount /dev/sdc2 /mnt
#
# pacman -Sy
# pacman -S ntfs-3g
# mount /dev/sdb1 /ntfs

pacstrap /mnt base base-devel linux linux-firmware nano git ntfs-3g grub-bios os-prober
genfstab -p /mnt/ >> /mnt/etc/fstab
arch-chroot /mnt
echo "Continuar con el siguiente comando:"
echo "sh /exfat/scripts/kde.sh"
