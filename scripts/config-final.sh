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

# Instalar Google Chrome
echo "Instalando Google Chrome desde AUR..."
yay -S --noconfirm google-chrome || { echo "Error al instalar Google Chrome"; exit 1; }

# Instalar paquetes de NVIDIA y CUDA
echo "Instalando los controladores NVIDIA, DKMS, nvidia-settings y CUDA..."
yay -S --noconfirm nvidia dkms nvidia-settings nvidia-utils cuda || { echo "Error al instalar NVIDIA o CUDA"; exit 1; }

echo "Todo instalado con éxito."
