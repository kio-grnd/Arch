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
# PAQUETES
pacman -S gnome gnome-extra --noconfirm --needed
pacman -S xorg linux-headers dkms adobe-source-code-pro-fonts zsh zsh-completions networkmanager git curl wget gcc make gimp firefox firefox-i18n-es-ar vlc zip unzip unrar p7zip libreoffice-fresh libreoffice-fresh-es youtube-dl ttf-dejavu flatpak --noconfirm --needed
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
# Teclado X11 en ES
cd /
mkdir /etc/X11/xorg.conf.d/
cp /mnt/ntfs/Linux/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d/
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
# Servicios
systemctl enable gdm
systemctl enable NetworkManager
systemctl enable bluetooth.service
exit
echo -e "\e[92m\e[1m¡Todo hecho! Reiniciar! \e[0m"

