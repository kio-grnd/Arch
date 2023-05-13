#/bin/bash
# Script al ejecutar archroot /mnt
# mount /dev/sdb1 /ntfs
# ATENTO AL NOMBRE DEL DISCO PARA INSTALAR GRUB
useradd -m -g users -G wheel,audio,lp,optical,storage,video,games,power,scanner -s /bin/bash cesc
usermod -c "Cesc" cesc
passwd cesc
passwd
echo "LANG=es_AR.UTF-8" >> /etc/locale.conf
echo "KEYMAP=es" >> /etc/vconsole.conf
echo "midna" >> /etc/hostname
echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
echo "es_AR ISO-8859-1" >> /etc/locale.gen
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
locale-gen
# GRUB
pacman --noconfirm --needed -S grub-bios os-prober
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install /dev/sda && grub-mkconfig -o /boot/grub/grub.cfg
# LINUX
mkinitcpio -p linux
# PAQUETES
pacman --noconfirm --needed -S networkmanager xorg xorg-xrdb xorg-xrandr xorg-xkill xorg-xinit i3 dmenu rofi firefox firefox-i18n-es-ar ranger ueberzug wget curl zsh zsh-completions xterm rxvt-unicode xarchiver xbindkeys figlet pulseaudio pulseaudio-alsa pavucontrol pulseaudio-equalizer-ladspa unrar unzip zip vim p7zip linux-headers dkms gcc make alsa-plugins alsa-tools alsa-utils imagemagick feh picom ttf-bitstream-vera ttf-droid ttf-dejavu htop terminus-font raw-thumbnailer ttf-font-awesome wmctrl lxappearance pcmanfm libreoffice-fresh-es libreoffice-fresh audacity gimp vlc xclip maim npm viewnior zathura zathura-pdf-poppler mpd mpc ncmpcpp ffmpeg xorg-xsetroot ttf-roboto picom flatpak picom-jonaburg-fix dunst pfetch thunar neovim cava qtile python-psutil starship playerctl
# Activar net & bluetooth
systemctl enable NetworkManager
systemctl enable bluetooth.service
# Teclado X11 en ES
cd /
mkdir /etc/X11/xorg.conf.d/
cp /mnt/ntfs/Linux/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d/
# Quita el horrendo cursor de espera
# Copia de seguridad en /root/backup/ y reemplazo de iconos
sudo mkdir /root/backup && sudo mkdir /root/backup/icons/
sudo cp -R /usr/share/icons/Adwaita/cursors/ /root/backup/icons/
sudo cp /usr/share/icons/Adwaita/cursors/arrow /usr/share/icons/Adwaita/cursors/wait
sudo cp /usr/share/icons/Adwaita/cursors/arrow /usr/share/icons/Adwaita/cursors/watch
sudo cp /usr/share/icons/Adwaita/cursors/arrow /usr/share/icons/Adwaita/cursors/progress
