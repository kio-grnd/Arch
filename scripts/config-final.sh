#!/bin/bash

# Instalar yay desde AUR
echo "Clonando y construyendo yay desde AUR..."
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -si --noconfirm
cd ~
rm -rf /tmp/yay

# Instalar Zsh y establecerlo como shell predeterminado
echo "Instalando Zsh y configurando como shell predeterminado..."
pacman -S --noconfirm zsh
chsh -s /bin/zsh

# Instalar Oh-My-Zsh
echo "Instalando Oh-My-Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Instalar Google Chrome
echo "Instalando Google Chrome con yay..."
yay -S --noconfirm google-chrome

# Instalar paquetes de NVIDIA y CUDA
echo "Instalando los controladores NVIDIA, DKMS, nvidia-settings y CUDA..."
yay -S --noconfirm nvidia dkms nvidia-settings cuda

# Fin
echo "La configuración final se ha completado con éxito."
