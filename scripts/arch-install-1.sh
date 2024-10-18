#!/bin/bash

# -----------------------------
# Variables generales del script
# -----------------------------
# read -p "Introduce el nombre del disco (ejemplo: /dev/sda): " DISK
# read -p "Introduce el tamaño de la partición swap (ejemplo: 2G): " SWAPSIZE
read -p "Introduce el nombre del host: " HOSTNAME
read -p "Introduce tu nombre de usuario: " USERNAME

# -----------------------------
# Particionamiento
# -----------------------------
# echo "Particionando el disco..."
# echo "Confirmando particiones..."
read -p "Introduce la partición raíz (ejemplo: /dev/sda1): " ROOT_PARTITION
read -p "Introduce la partición swap (ejemplo: /dev/sda2): " SWAP_PARTITION

# mkfs.ext4 $ROOT_PARTITION
# mkswap $SWAP_PARTITION
# swapon $SWAP_PARTITION
# mount $ROOT_PARTITION /mnt

# -----------------------------
# Instalación base del sistema
# -----------------------------
pacstrap /mnt base linux linux-firmware vim nano

genfstab -U /mnt >> /mnt/etc/fstab

# -----------------------------
# Finalización
# -----------------------------
echo "Instalación base completada. Para continuar, ejecuta 'arch-chroot /mnt' y luego ejecuta 'bash setup.sh' para la configuración."
