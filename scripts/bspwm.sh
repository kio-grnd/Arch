#/bin/bash
# Script al ejecutar archroot /mnt
# mount /dev/sdb1 /ntfs
# ATENTO AL NOMBRE DEL DISCO PARA INSTALAR GRUB

useradd -m -g users -G wheel,audio,lp,optical,storage,video,games,power,scanner -s /bin/bash sid
usermod -c "SiDnEy!" sid
passwd sid
passwd
echo "LANG=es_AR.UTF-8" >> /etc/locale.conf
echo "KEYMAP=es" >> /etc/vconsole.conf

# echo "midna" >> /etc/hostname
echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
echo "es_AR ISO-8859-1" >> /etc/locale.gen
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
locale-gen

# Update system 
sudo pacman -Syu

# GRUB
pacman --noconfirm --needed -S grub-bios os-prober
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install /dev/sda && grub-mkconfig -o /boot/grub/grub.cfg

# LINUX
mkinitcpio -p linux

# Clone and install Paru
if command -v paru &>/dev/null; then
  echo "Paru $(paru -V | cut -d' ' -f2) is already installed in your system"
else
  if command -v yay &>/dev/null; then
    echo "Yay $(yay -V | cut -d' ' -f2) is installed in your system"
  else
    echo "Neither Paru nor Yay is present in your system."
    echo "Installing Paru..."
    git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm && cd ..
  fi
fi 

# PAQUETES
paru -Syu networkmanager xorg xorg-xrdb xorg-xrandr xorg-xkill xorg-xinit bspwm sxhkd i3 dmenu rofi firefox firefox-i18n-es-ar ranger ueberzug wget curl zsh zsh-completions xterm rxvt-unicode xarchiver xbindkeys figlet pulseaudio pulseaudio-alsa pavucontrol pulseaudio-equalizer-ladspa unrar unzip zip vim p7zip linux-headers dkms gcc make alsa-plugins alsa-tools alsa-utils imagemagick feh picom ttf-bitstream-vera ttf-droid ttf-dejavu htop terminus-font ttf-font-awesome wmctrl lxappearance pcmanfm libreoffice-fresh-es libreoffice-fresh audacity gimp vlc xclip maim npm viewnior zathura zathura-pdf-poppler mpd mpc ncmpcpp ffmpeg xorg-xsetroot ttf-roboto picom dunst thunar neovim python-psutil starship playerctl brightnessctl alacritty picom-jonaburg-fix python-psutil pywal-git cava --noconfirm --needed 

# Check and set Zsh as the default shell
[[ "$(awk -F: -v user="$USER" '$1 == user {print $NF}' /etc/passwd) " =~ "zsh " ]] || chsh -s $(which zsh)


# Install Oh My Zsh
if [ ! -d ~/.oh-my-zsh/ ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 
else
  omz update
fi

# Install Zsh plugins
[[ "${plugins[*]} " =~ "zsh-autosuggestions " ]] || git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
[[ "${plugins[*]} " =~ "zsh-syntax-highlighting " ]] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Activar net & bluetooth
systemctl enable NetworkManager
systemctl enable bluetooth.service

# Teclado X11 en ES
mkdir /etc/X11/xorg.conf.d/
cd /
cp /mnt/ntfs/Linux/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d/

