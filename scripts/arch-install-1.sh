#!/bin/bash

# Este script automatiza la instalación básica de Arch Linux en un entorno BIOS con idioma español de Argentina.
# El script asume que ya has particionado y formateado el disco, y montado la partición en /mnt.

# Paso 1: Configurar el teclado en español
echo "Configurando el teclado en español..."
loadkeys es

# Paso 2: Instalar los paquetes esenciales y herramientas para compilar
echo "Instalando paquetes esenciales y herramientas para compilar..."
pacstrap /mnt base linux linux-firmware networkmanager base-devel git linux-headers

# Paso 3: Generar el archivo fstab
echo "Generando el archivo fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Paso 4: Cambiar al nuevo sistema chroot
echo "Cambiando al nuevo sistema chroot..."
arch-chroot /mnt <<EOF

# Paso 5: Configuración de la zona horaria
echo "Configurando la zona horaria..."
ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
hwclock --hctosys

# Paso 6: Configuración de la localización
echo "Configurando la localización..."
sed -i 's/#es_AR.UTF-8/es_AR.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=es_AR.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf

# Paso 7: Configuración del nombre del host
echo "Por favor ingresa el nombre de tu máquina (host):"
read hostname
echo $hostname > /etc/hostname

# Paso 8: Configuración de la contraseña de root
echo "Estableciendo la contraseña de root..."
passwd

# Paso 9: Instalación de GRUB
echo "Por favor, ingresa el disco donde quieres instalar GRUB (ej. /dev/sda):"
read grub_disk

# Verificar si el disco existe antes de proceder con la instalación
if [ -b "$grub_disk" ]; then
    echo "Instalando GRUB en $grub_disk..."
    pacman -S --noconfirm grub

    # Instalar GRUB
    grub-install --target=i386-pc $grub_disk

    # Generar el archivo de configuración de GRUB
    echo "Generando el archivo de configuración de GRUB..."
    grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "Error: El disco $grub_disk no existe. Verifique el nombre y vuelva a intentarlo."
    exit 1
fi

# Paso 10: Activar y habilitar NetworkManager
echo "Activando y habilitando NetworkManager..."
systemctl enable NetworkManager
systemctl start NetworkManager

# Paso 11: Crear un usuario
echo "Creando un nuevo usuario..."

# Solicitar el nombre de usuario
read -p "Ingrese el nombre de usuario que desea crear: " usuario

# Solicitar el nombre completo
read -p "Ingrese el nombre completo del usuario: " nombre_completo

# Crear el usuario y establecer su grupo y shell
if useradd -m -g users -G wheel,audio,lp,optical,storage,video,games,power,scanner -s /bin/bash "$usuario"; then
    echo "Usuario '$usuario' creado."
else
    echo "Error: No se pudo crear el usuario '$usuario'." >&2
    exit 1
fi

# Establecer el nombre completo del usuario
if usermod -c "$nombre_completo" "$usuario"; then
    echo "Nombre completo del usuario '$usuario' establecido."
else
    echo "Error: No se pudo establecer el nombre completo." >&2
    exit 1
fi

# Establecer la contraseña del usuario
if passwd "$usuario"; then
    echo "Contraseña establecida."
else
    echo "Error: No se pudo establecer la contraseña para '$usuario'." >&2
    exit 1
fi

echo "Usuario '$usuario' creado exitosamente con el nombre completo '$nombre_completo'."

# Paso 12: Salir del chroot
exit

EOF

# Paso 13: Reiniciar el sistema
echo "Instalación completada. Puedes reiniciar el sistema ahora."
# Recomendación: Desmontar las particiones antes de reiniciar (si aún no lo has hecho)
# umount -R /mnt
# reboot
