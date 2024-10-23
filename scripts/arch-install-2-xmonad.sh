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
# Instalación de XMonad y Xmobar
# -----------------------------
pacman -S --noconfirm --needed xmonad xmonad-contrib xmobar

# -----------------------------
# Instalación de utilidades necesarias
# -----------------------------
pacman -S --noconfirm --needed kitty xterm dmenu rofi feh picom htop numlockx loupe lxappearance neovim git bat ranger ueberzug wget curl zsh zsh-completions xbindkeys rxvt-unicode ttf-bitstream-vera

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
picom & 
xsetroot -cursor_name left_ptr &
exec xmonad
EOF
chmod +x /home/$USERNAME/.xinitrc
chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc

# -----------------------------
# Copiar dotfiles a la carpeta home
# -----------------------------
echo "Clonando dotfiles desde GitHub..."
git clone https://github.com/vetealdiablo/Arch.git /tmp/arch

echo "Copiando dotfiles a /home/$USERNAME..."
cp -r /tmp/arch/dotfiles/.* /home/$USERNAME/

# Cambiar el propietario de los archivos copiados al usuario correspondiente
chown -R $USERNAME:$USERNAME /home/$USERNAME/.*
# Cambiar los permisos de los archivos copiados
chmod -R u+rwX /home/$USERNAME/.*

# Limpiar
rm -rf /tmp/arch

# -----------------------------
# Instalación de Oh My Zsh y configuración de Zsh como shell predeterminada
# -----------------------------
echo "Instalando Oh My Zsh..."
sudo -u $USERNAME sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Cambiar shell predeterminada a Zsh
chsh -s /bin/zsh $USERNAME

# -----------------------------
# Elegir donde instalar GRUB
# -----------------------------
read -p "Introduce el dispositivo donde instalar GRUB (ejemplo: /dev/sda): " DISCO

# Validar que el dispositivo sea correcto
if [[ ! -b $DISCO ]]; then
    echo -e "\e[31mError: El dispositivo $DISCO no es válido.\e[0m"
    exit 1
fi

# Instalación de GRUB y os-prober
echo -e "\e[34mInstalando GRUB y os-prober...\e[0m"
pacman -S grub os-prober --noconfirm
if [[ $? -ne 0 ]]; then
    echo -e "\e[31mError: La instalación de GRUB y os-prober ha fallado.\e[0m"
    exit 1
fi

# Instalar GRUB en el dispositivo (disco completo, no una partición)
echo -e "\e[34mInstalando GRUB en $DISCO...\e[0m"
grub-install "$DISCO"
if [[ $? -ne 0 ]]; then
    echo -e "\e[31mError: La instalación de GRUB ha fallado.\e[0m"
    exit 1
fi

# Habilitar os-prober para detectar otros sistemas operativos
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub

# Generar el archivo de configuración de GRUB
echo -e "\e[34mGenerando el archivo de configuración de GRUB...\e[0m"
grub-mkconfig -o /boot/grub/grub.cfg
if [[ $? -ne 0 ]]; then
    echo -e "\e[31mError: La generación del archivo de configuración de GRUB ha fallado.\e[0m"
    exit 1
fi

# -----------------------------
# Finalización
# -----------------------------
echo -e "\e[32mEl script ha finalizado correctamente.\e[0m"
umount -R /mnt
reboot
