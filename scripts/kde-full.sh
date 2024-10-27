#!/bin/bash

# -----------------------------
# Establecer el teclado en español
# -----------------------------
loadkeys es

# -----------------------------
# Preguntar al usuario por nombre de host y nombre de usuario
# -----------------------------
read -p "Introduce el nombre de host: " HOSTNAME
read -p "Introduce el nombre de usuario: " USERNAME

# -----------------------------
# Configuración inicial del sistema
# -----------------------------

ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
hwclock --systohc

echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_AR.UTF-8" > /etc/locale.conf

echo $HOSTNAME > /etc/hostname
{
    echo "127.0.0.1    localhost"
    echo "::1          localhost"
    echo "127.0.1.1    $HOSTNAME.localdomain $HOSTNAME"
} >> /etc/hosts

passwd

useradd -m -G wheel "$USERNAME"
passwd "$USERNAME"
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# -----------------------------
# Mostrar discos y particiones disponibles
# -----------------------------

echo "Mostrando discos y particiones disponibles:"
lsblk

echo "Usa el comando 'fdisk -l' o 'lsblk -f' para detalles adicionales."
read -p "Presiona Enter para continuar..."

# -----------------------------
# Instalación y configuración de GRUB
# -----------------------------

read -p "Introduce el dispositivo donde instalar GRUB (ejemplo: /dev/sda): " DISCO

# Validar que el dispositivo sea correcto
if [[ ! -b $DISCO ]]; then
    echo -e "\e[31mError: El dispositivo $DISCO no es válido.\e[0m"
    exit 1
fi

# Instalación de GRUB y os-prober
echo -e "\e[34mInstalando GRUB y os-prober...\e[0m"
pacman -S grub os-prober --noconfirm || { echo -e "\e[31mError: La instalación de GRUB y os-prober ha fallado.\e[0m"; exit 1; }

# Instalar GRUB en el dispositivo
echo -e "\e[34mInstalando GRUB en $DISCO...\e[0m"
grub-install "$DISCO" || { echo -e "\e[31mError: La instalación de GRUB ha fallado.\e[0m"; exit 1; }

# Habilitar os-prober
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub

# Generar el archivo de configuración de GRUB
echo -e "\e[34mGenerando el archivo de configuración de GRUB...\e[0m"
grub-mkconfig -o /boot/grub/grub.cfg || { echo -e "\e[31mError: La generación del archivo de configuración de GRUB ha fallado.\e[0m"; exit 1; }

# -----------------------------
# Instalación de controladores NVIDIA y configuración de gráficos
# -----------------------------

pacman -S nvidia nvidia-utils nvidia-settings --noconfirm

# Desactivar Nouveau
{
    echo "blacklist nouveau"
    echo "options nouveau modeset=0"
} >> /etc/modprobe.d/blacklist.conf
echo "drm.modeset=0" >> /boot/loader/entries/arch.conf

# -----------------------------
# Instalación de Xorg (servidor gráfico)
# -----------------------------

pacman -S xorg xorg-server xorg-xinit --noconfirm

# -----------------------------
# Configuración de sonido (PipeWire)
# -----------------------------

pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber alsa-utils --noconfirm
systemctl --user enable wireplumber
systemctl --user start wireplumber
alsamixer

# -----------------------------
# Configuración de NetworkManager
# -----------------------------

pacman -S --noconfirm --needed networkmanager
systemctl enable NetworkManager
systemctl start NetworkManager

# -----------------------------
# Instalación de XMonad y Xmobar
# -----------------------------

pacman -S --noconfirm --needed xmonad xmonad-contrib xmobar

# -----------------------------
# Instalación de utilidades esenciales
# -----------------------------

pacman -S --noconfirm --needed htop git zsh zsh-completions plasma kde-applications

# -----------------------------
# Instalación de SDDM
# -----------------------------

echo -e "\e[34mInstalando SDDM...\e[0m"
pacman -S sddm --noconfirm

# Habilitar SDDM para que se inicie al arranque
systemctl enable sddm.service

# Configuración básica de SDDM
echo -e "\e[34mConfigurando SDDM...\e[0m"
cat << EOF > /etc/sddm.conf
[General]
NumLock=on

[Theme]
Current=Arc
EOF

# -----------------------------
# Instalación de compiladores y herramientas de desarrollo
# -----------------------------

pacman -S --noconfirm --needed git base-devel gcc make dkms linux-headers gd cmake python python-pip go rust

# -----------------------------
# Instalación de soporte NTFS y herramientas de descompresión
# -----------------------------

pacman -S --noconfirm --needed ntfs-3g unzip p7zip

# -----------------------------
# Instalación y configuración de Bluetooth
# -----------------------------

pacman -S bluez bluez-utils --noconfirm
systemctl enable bluetooth.service
systemctl start bluetooth.service
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
# Instalación de Oh My Zsh para usuario y root
# -----------------------------

echo "Instalando Oh My Zsh para el usuario $USERNAME..."
sudo -u "$USERNAME" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Instalando Oh My Zsh para root..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Cambiar la shell predeterminada a Zsh para el usuario y root
chsh -s /bin/zsh "$USERNAME"
chsh -s /bin/zsh root

# Agregar PATH personalizado a ~/.zshrc del usuario
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "/home/$USERNAME/.zshrc"
chown "$USERNAME:$USERNAME" "/home/$USERNAME/.zshrc"

# Agregar PATH personalizado a ~/.zshrc de root
echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.zshrc

# Recargar la shell para aplicar Zsh y cambios en PATH inmediatamente
echo "Recargando shell para aplicar Zsh y cambios en PATH..."
sudo -u "$USERNAME" zsh -c "source ~/.zshrc"
zsh -c "source ~/.zshrc"

# -----------------------------
# Finalización
# -----------------------------

echo -e "\e[32mEl script ha finalizado correctamente.\e[0m"
umount -R /mnt
reboot
