#/bin/bash

echo "LANG=es_AR.UTF-8" >> /etc/locale.conf
echo "KEYMAP=es" >> /etc/vconsole.conf
echo "midna" >> /etc/hostname
echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
echo "es_AR ISO-8859-1" >> /etc/locale.gen
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
locale-gen
grub-install /dev/sdb
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux
useradd -m -g users -G wheel,audio,lp,optical,storage,video,games,power,scanner -s /bin/bash cesc
usermod -c "Cesc" cesc
passwd cesc
pacman -S xorg xorg-apps xorg-xinit xorg-fonts-misc xorg-xfd nvidia nvidia-settings nvidia-utils i3 dmenu rofi firefox firefox-i18n-es-ar ranger ueberzug lightdm lightdm-gtk-greeter-settings terminus-font adobe-source-code-pro-fonts noto-fonts ttf-ubuntu-font-family ttf-dejavu ttf-font-awesome ttf-liberation libreoffice-fresh-es libreoffice-fresh audacity gimp git wget xdg-user-dirs xdg-utils usbutils vlc glances xarchiver xbindkeys screenfetch figlet breeze-icons lxappearance pcmanfm xterm rxvt-unicode feh picom viewnior epdfview moc mousepad geany geany-plugins nitrogen qt5ct pulseaudio pulseaudio-alsa pavucontrol pulseaudio-equalizer-ladspa unzip zip vim p7zip unrar bspwm sxhkd gnome ttf-font-awesome adobe-source-code-pro-fonts zsh zsh-completions
nvidia-xconfig
systemctl enable lightdm
systemctl enable NetworkManager
passwd
cp /mnt/Linux/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d/
