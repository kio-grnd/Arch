#/bin/bash
# Script al ejecutar archroot /mnt
# mount /dev/sdb1 /ntfs
# ATENTO AL NOMBRE DEL DISCO PARA INSTALAR GRUB
useradd -m -g users -G wheel,audio,lp,optical,storage,video,games,power,scanner -s /bin/bash kio
usermod -c "Kio" kio
passwd kio
passwd
echo "LANG=es_AR.UTF-8" >> /etc/locale.conf
echo "KEYMAP=es" >> /etc/vconsole.conf
echo "adamantium" >> /etc/hostname
echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
echo "es_AR ISO-8859-1" >> /etc/locale.gen
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
locale-gen
# GRUB
pacman --noconfirm --needed -S grub-bios os-prober
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install /dev/sda && grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux
pacman -S xorg zsh zsh-completions zsh-syntax-highlighting zsh-history-substring-search networkmanager plasma curl wget gcc make dkms sddm dolphin kate konsole extra/gwenview firefox firefox-i18n-es-ar thunderbird-i18n-es-ar gimp linux-headers vlc ark okular zip unzip unrar p7zip spectacle alacritty kalarm kaddressbook kcalc kwrite
# Para instalar las aplicaciones KDE
# sudo pacman -S kde-applications-meta
# sudo pacman -S kde-applications
systemctl enable sddm
systemctl enable NetworkManager
systemctl enable bluetooth.service
# Teclado X11 en ES
cd /
mkdir /etc/X11/xorg.conf.d/
cp /mnt/ntfs/Linux/xorg.conf.d/00-keyboard.conf /etc/X11/xorg.conf.d/
# Reemplazar cursor wait y watch
mkdir /root/backup/ && mkdir /root/backup/icons/
cp -r /usr/share/icons/breeze_cursors /root/backup/icons/
cd /usr/share/icons/breeze_cursors/cursors
cp arrow wait
cp arrow watch
cp arrow left_ptr_watch
cp arrow half-busy
cp arrow progress
cp -r /ntfs/Linux/cursores/Mickey_mouse /usr/share/icons/
cd
# Finalizar
exit
exit && reboot
