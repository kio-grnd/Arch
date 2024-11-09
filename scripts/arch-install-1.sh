#!/bin/bash

# Este script automatiza la instalación básica de Arch Linux en un entorno BIOS con idioma español de Argentina.
# Permite elegir el nombre del host, la zona horaria y el disco para instalar GRUB.

# Paso 1: Instalar los paquetes esenciales
echo "Instalando paquetes esenciales..."
pacstrap -K /mnt base linux linux-firmware

# Paso 2: Generar el archivo fstab
echo "Generando el archivo fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Paso 3: Cambiar al nuevo sistema chroot
echo "Cambiando al sistema chroot..."
arch-chroot /mnt <<EOF

# Paso 4: Configuración de la zona horaria
echo "Configurando la zona horaria..."
ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
hwclock --hctosys

# Paso 5: Configuración de la localización
echo "Configurando la localización..."
sed -i 's/#es_AR.UTF-8/es_AR.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=es_AR.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf

# Paso 6: Configuración del nombre del host
echo "Por favor ingresa el nombre de tu máquina (host):"
read hostname
echo $hostname > /etc/hostname

# Paso 7: Configuración de la contraseña de root
echo "Estableciendo la contraseña de root..."
passwd

# Paso 8: Instalación y configuración de GRUB
# Permite elegir el disco donde instalar GRUB
echo "Por favor, ingresa el disco donde quieres instalar GRUB (ej. /dev/sda):"
read grub_disk
echo "Instalando GRUB en $grub_disk..."
pacman -S --noconfirm grub
grub-install --target=i386-pc $grub_disk

# Paso 9: Generación del archivo de configuración de GRUB
echo "Generando el archivo de configuración de GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg

# Paso 10: Salir del chroot
exit

# Paso 11: Reiniciar el sistema
# echo "Instalación completada. Reiniciando el sistema..."
# reboot

EOF
