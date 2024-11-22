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
# Instalación de controladores NVIDIA
# Comentar para instalar los controladores manualmente
# Instalar desde config-final.sh
# -----------------------------
# pacman -S nvidia nvidia-utils nvidia-settings --noconfirm

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
# pacman -S bluez bluez-utils --noconfirm

# Habilitar el servicio Bluetooth
# systemctl enable bluetooth.service
# systemctl start bluetooth.service

# Configurar para iniciar con bluetoothctl
# echo -e "power on\nagent on\ndefault-agent\n" | bluetoothctl

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
git clone https://github.com/vetealdiablo/arch.git /tmp/arch

echo "Copiando dotfiles a /home/$USERNAME..."
cp -r /tmp/arch/dotfiles/.* /home/$USERNAME/

# Cambiar el propietario de los archivos copiados al usuario correspondiente
chown -R $USERNAME:$USERNAME /home/$USERNAME/.*
# Cambiar los permisos de los archivos copiados
chmod -R u+rwX /home/$USERNAME/.*
# chmod -R 777 /home/$USERNAME/.*
# chmod -R 777 /home/$USERNAME/*
# Limpiar
rm -rf /tmp/arch

# -----------------------------
# Detectar si el sistema es UEFI o BIOS
# -----------------------------
if [ -d /sys/firmware/efi ]; then
    BOOT_MODE="UEFI"
else
    BOOT_MODE="BIOS"
fi

echo "Modo de arranque detectado: $BOOT_MODE"

# -----------------------------
# Selección del disco para instalar GRUB
# -----------------------------
echo -e "\nSeleccione el disco en el que desea instalar GRUB (ejemplo: /dev/sdd):"
lsblk
read -p "Introduce el disco deseado: " GRUB_DISK

# Verificar si el disco elegido es válido
if [ ! -b "$GRUB_DISK" ]; then
    echo "El disco $GRUB_DISK no es válido."
    exit 1
fi

# -----------------------------
# Instalación de GRUB dependiendo del modo de arranque (UEFI o BIOS)
# -----------------------------
if [ "$BOOT_MODE" == "UEFI" ]; then
    pacman -S --noconfirm grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
else
    pacman -S --noconfirm grub
    grub-install --target=i386-pc $GRUB_DISK
fi

# Generar la configuración de GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# -----------------------------
# Crear script para terminar la configuración en el directorio del usuario
# -----------------------------

echo "Creando script de configuración final..."

cat << EOF > /home/$USERNAME/configuracion_final.sh
#!/bin/bash

# Instalar yay desde AUR
echo "Clonando y construyendo yay desde AUR..."
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
cd ~
rm -rf /tmp/yay

# Instalar Zsh y establecerlo como shell predeterminado
echo "Instalando Zsh..."
sudo pacman -S --noconfirm zsh || { echo "Error al instalar Zsh"; exit 1; }
echo "Configurando Zsh como shell predeterminado..."
sudo chsh -s /bin/zsh "$USER" || { echo "Error al cambiar el shell"; exit 1; }

# Instalar Oh-My-Zsh
echo "Instalando Oh-My-Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended

# Instalar Google Chrome
echo "Instalando Google Chrome desde AUR..."
yay -S --noconfirm google-chrome || { echo "Error al instalar Google Chrome"; exit 1; }

# Instalar paquetes de NVIDIA y CUDA
echo "Instalando los controladores NVIDIA, DKMS, nvidia-settings y CUDA..."
yay -S --noconfirm nvidia dkms nvidia-settings nvidia-utils cuda || { echo "Error al instalar NVIDIA o CUDA"; exit 1; }

echo "Todo instalado con éxito."

EOF

# Hacer ejecutable el script
chmod +x /home/$USERNAME/configuracion_final.sh
chown $USERNAME:$USERNAME /home/$USERNAME/configuracion_final.sh

# Informar al usuario
echo "Se ha creado el script de configuración final en /home/$USERNAME/configuracion_final.sh"
echo "Ejecuta el script para completar la configuración."

# -----------------------------
# Finalización
# -----------------------------
echo -e "\e[32mEl script ha finalizado correctamente.\e[0m"

