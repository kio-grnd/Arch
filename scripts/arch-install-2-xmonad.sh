#!/bin/bash

# -----------------------------
# Establecer el teclado en español
# -----------------------------
echo "Estableciendo el teclado en español..."
loadkeys es
echo "KEYMAP=es" > /etc/vconsole.conf

# -----------------------------
# Preguntar al usuario por nombre de host y nombre de usuario
# -----------------------------
read -p "Introduce el nombre de host: " HOSTNAME
read -p "Introduce el nombre de usuario: " USERNAME

# -----------------------------
# Verificar si el usuario ya existe
# -----------------------------
if id "$USERNAME" &>/dev/null; then
    echo "El usuario '$USERNAME' ya existe. No se creará un nuevo usuario."
else
    # Si el usuario no existe, crear el usuario
    useradd -m -G wheel $USERNAME
    passwd $USERNAME
    if ! grep -q '%wheel' /etc/sudoers; then
        echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
    fi
fi

# -----------------------------
# Configuración inicial del sistema
# -----------------------------
echo "Configurando la zona horaria..."
ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
hwclock --systohc --localtime

echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_AR.UTF-8" > /etc/locale.conf

echo $HOSTNAME > /etc/hostname
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

passwd

# -----------------------------
# Instalación de controladores NVIDIA y configuración de gráficos
# -----------------------------
# pacman -S nvidia nvidia-utils nvidia-settings --noconfirm

# Desactivar Nouveau (si es necesario)
# echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
# echo "options nouveau modeset=0" >> /etc/modprobe.d/nouveau.conf
# echo "drm.modeset=0" >> /boot/loader/entries/arch.conf

# -----------------------------
# Instalación de Xorg (servidor gráfico)
# -----------------------------
echo "Instalando Xorg..."
pacman -S --noconfirm --needed xorg xorg-server xorg-xinit

# -----------------------------
# Configuración de sonido (PipeWire)
# -----------------------------
echo "Instalando PipeWire y configurando sonido..."
pacman -S --noconfirm --needed pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber alsa-utils
systemctl --user enable wireplumber
systemctl --user start wireplumber
alsamixer

# -----------------------------
# Configuración de NetworkManager
# -----------------------------
echo "Instalando y habilitando NetworkManager..."
pacman -S --noconfirm --needed networkmanager
systemctl enable NetworkManager
systemctl start NetworkManager

# -----------------------------
# Instalación de XMonad y Xmobar
# -----------------------------
echo "Instalando XMonad y Xmobar..."
pacman -S --noconfirm --needed xmonad xmonad-contrib xmobar

# -----------------------------
# Instalación de utilidades esenciales
# -----------------------------
echo "Instalando utilidades esenciales..."
pacman -S --noconfirm --needed kitty xterm dmenu fish polybar rofi feh picom htop numlockx loupe lxappearance neovim git bat ranger ueberzug wget curl zsh zsh-completions xbindkeys rxvt-unicode ttf-bitstream-vera

# -----------------------------
# Instalación de compiladores y herramientas de desarrollo
# -----------------------------
echo "Instalando herramientas de desarrollo..."
pacman -S --noconfirm --needed git base-devel gcc make ninja linux-headers gd cmake python python-pip go rust

# -----------------------------
# Instalación de soporte NTFS y herramientas de descompresión
# -----------------------------
echo "Instalando soporte NTFS y herramientas de descompresión..."
pacman -S --noconfirm --needed ntfs-3g unzip p7zip

# -----------------------------
# Instalación y configuración de Bluetooth
# -----------------------------
# echo "Instalando y configurando Bluetooth..."

# Instalación de paquetes necesarios
# pacman -S --noconfirm --needed bluez bluez-utils

# Habilitar e iniciar el servicio bluetooth
# systemctl enable bluetooth.service
# systemctl start bluetooth.service

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
mkdir -p /home/$USERNAME
cat << EOF > /home/$USERNAME/.xinitrc
#!/bin/bash

# ~/.xinitrc

# Configuración del teclado
setxkbmap es

# Iniciar xbindkeys para atajos de teclado
xbindkeys &

# Cargar configuraciones gráficas de X11
xrdb -merge ~/.Xresources &

# Activar NumLock al inicio
numlockx on &

# Iniciar compositor gráfico (opcional)
# picom &

# Iniciar Polybar
polybar &

# Establecer cursor por defecto
xsetroot -cursor_name left_ptr &

# Iniciar xmonad
exec xmonad
EOF
chmod +x /home/$USERNAME/.xinitrc
chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc

# -----------------------------
# Clonación de dotfiles de XMonad desde GitHub
# -----------------------------
echo "Clonando dotfiles desde GitHub..."
git clone https://github.com/vetealdiablo/Arch.git /tmp/arch

echo "Copiando dotfiles a /home/$USERNAME..."
cp -r /tmp/arch/xmonad/* /tmp/arch/xmonad/.[!.]* /home/$USERNAME/

chown -R $USERNAME:$USERNAME /home/$USERNAME/.* 
chmod -R u+rwX /home/$USERNAME/.* 

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

# Instalar Google Chrome desde AUR
echo "Instalando Google Chrome desde AUR..."
yay -S --noconfirm google-chrome || { echo "Error al instalar Google Chrome"; exit 1; }

# Instalar paquetes de NVIDIA y CUDA
echo "Instalando los controladores NVIDIA, DKMS, nvidia-settings y CUDA..."
yay -S --noconfirm dkms nvidia nvidia-settings nvidia-utils cuda || { echo "Error al instalar NVIDIA o CUDA"; exit 1; }

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
