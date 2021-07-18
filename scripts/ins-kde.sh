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
useradd -m -g users -G wheel,audio,lp,optical,storage,video,games,power,scanner -s /bin/bash kio
useradd -m -g users -G wheel,audio,lp,optical,storage,video,games,power,scanner -s /bin/bash cesc
usermod -c "kio" kio
usermod -c "Cesc" cesc
passwd kio
passwd cesc
pacman -S xorg xorg-fonts-misc ttf-font-awesome adobe-source-code-pro-fonts sddm zsh zsh-completions nvidia nvidia-settings nvidia-utils networkmanager plasma konsole kate dolphin
sudo nvidia-xconfig
sudo systemctl enable sddm
sudo systemctl enable NetworkManager
passwd
