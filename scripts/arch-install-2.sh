#!/bin/bash

# -----------------------------
# Configuración del sistema
# -----------------------------
read -p "Introduce el nombre del host: " HOSTNAME
read -p "Introduce tu nombre de usuario: " USERNAME

ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
hwclock --systohc

echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_AR.UTF-8" > /etc/locale.conf

echo $HOSTNAME > /etc/hostname
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

passwd

useradd -m -G wheel $USERNAME
passwd $USERNAME
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# -----------------------------
# Mostrar discos disponibles
# -----------------------------
echo "Discos disponibles:"
lsblk

# -----------------------------
# Elegir donde instalar GRUB
# -----------------------------
read -p "Introduce el dispositivo donde instalar GRUB (ejemplo: /dev/sda): " DISCO

# Instalación de GRUB y os-prober
pacman -S grub os-prober --noconfirm
# Instalar GRUB en el MBR
grub-install --target=i386-pc $DISCO
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# -----------------------------
# Instalación de controladores NVIDIA
# -----------------------------
pacman -S nvidia nvidia-utils nvidia-settings --noconfirm

# -----------------------------
# Desactivar Nouveau
# -----------------------------
echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
echo "options nouveau modeset=0" >> /etc/modprobe.d/nouveau.conf

# Crear un archivo de configuración para regenerar la inicialización
echo "drm.modeset=0" >> /boot/loader/entries/arch.conf

# -----------------------------
# Instalación de Xorg
# -----------------------------
pacman -S xorg xorg-server xorg-xinit --noconfirm

# -----------------------------
# Instalación y configuración de sonido (PipeWire)
# -----------------------------
pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber alsa-utils --noconfirm
systemctl --user enable wireplumber
systemctl --user start wireplumber

alsamixer

# -----------------------------
# Instalación de BSPWM y software necesario
# -----------------------------
pacman -S --noconfirm --needed bspwm sxhkd polybar rofi bat alacritty ranger ueberzug wget curl zsh zsh-completions rxvt-unicode feh htop lxappearance zathura zathura-pdf-poppler neovim alsa-utils

# -----------------------------
# Instalación de compiladores y herramientas de desarrollo
# -----------------------------
pacman -S --noconfirm --needed git base-devel gcc make dkms linux-headers gd cmake python python-pip go rust

# -----------------------------
# Instalación de soporte NTFS y herramientas de descompresión
# -----------------------------
pacman -S --noconfirm --needed ntfs-3g unzip p7zip

# -----------------------------
# Activar y configurar NetworkManager
# -----------------------------
pacman -S --noconfirm --needed networkmanager
systemctl enable NetworkManager
systemctl start NetworkManager

# -----------------------------
# Activar y configurar Bluetooth
# -----------------------------
pacman -S bluez bluez-utils --noconfirm

# Habilitar el servicio Bluetooth
systemctl enable bluetooth.service
systemctl start bluetooth.service

# Configurar para iniciar con bluetoothctl
echo -e "power on\nagent on\ndefault-agent\n" | bluetoothctl

# -----------------------------
# Configuración del teclado para X11 (ES)
# -----------------------------
echo "Configurando el teclado en español para X11..."
mkdir -p /etc/X11/xorg.conf.d/
cat << EOF > /etc/X11/xorg.conf.d/00-keyboard.conf
# Configuración del teclado en español para X11
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "es"
        Option "XkbModel" "pc105"
        Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
EOF

# -----------------------------
# Creación del archivo .xinitrc
# -----------------------------
echo "Creando el archivo .xinitrc..."
cat << EOF > /home/$USERNAME/.xinitrc
#!/bin/bash
setxkbmap es
xbindkeys &
numlockx on &
sxhkd &
picom &
xsetroot -cursor_name left_ptr &
exec bspwm
EOF
chmod +x /home/$USERNAME/.xinitrc
chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc

# -----------------------------
# Copiar dotfiles a la carpeta home
# -----------------------------
echo "Clonando dotfiles desde GitHub..."
git clone https://github.com/vetealdiablo/gentoo.git /tmp/gentoo

echo "Copiando dotfiles a /home/$USERNAME..."
cp -r /tmp/gentoo/dotfiles/.* /home/$USERNAME/

# Cambiar el propietario de los archivos copiados al usuario correspondiente
chown -R $USERNAME:$USERNAME /home/$USERNAME/.*
# Cambiar los permisos de los archivos copiados
chmod -R u+rwX /home/$USERNAME/.*

# Limpiar
rm -rf /tmp/gentoo

# -----------------------------
# Configuración de Zsh como shell predeterminada
# -----------------------------
# chsh -s /bin/zsh $USERNAME

# -----------------------------
# Finalización
# -----------------------------
echo -e "\e[32mEl script ha finalizado correctamente.\e[0m"
umount -R /mnt
reboot
