#!/bin/bash

# -----------------------------
# Variables generales del script
# -----------------------------

# -----------------------------
# Particionamiento
# -----------------------------
# read -p "Introduce la partición raíz (ejemplo: /dev/sda1): " ROOT_PARTITION
# read -p "Introduce la partición swap (ejemplo: /dev/sda2): " SWAP_PARTITION

# Formateo y montaje de las particiones (descomentar si se desea habilitar)
# mkfs.ext4 $ROOT_PARTITION
# mkswap $SWAP_PARTITION
# swapon $SWAP_PARTITION
# mount $ROOT_PARTITION /mnt

# -----------------------------
# Instalación base del sistema
# -----------------------------
pacstrap /mnt base linux linux-firmware vim nano git

genfstab -U /mnt >> /mnt/etc/fstab

# -----------------------------
# Configuración en chroot
# -----------------------------
echo "Instalación base completada. Ahora ejecutando 'arch-chroot /mnt'."

# Crear un archivo de configuración temporal
cat << EOF > /mnt/setup_choice.sh
#!/bin/bash
# Clonar el repositorio solo una vez
echo "Clonando el repositorio..."
git clone https://github.com/kio-grnd/Arch /tmp/arch-scripts

# Elegir entorno de escritorio
echo -e "\n¿Qué entorno de escritorio deseas instalar?"
select option in "i3" "bspwm" "xmonad" "Salir"; do
    case \$option in
        i3)
            echo "Ejecutando script de instalación de i3..."
            bash /tmp/arch-scripts/scripts/arch-install-2-i3.sh
            echo "Copiando dotfiles de i3..."
            cp -r /tmp/arch-scripts/i3 /home/$USERNAME/.config/i3
            chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/i3
            break
            ;;
        bspwm)
            echo "Ejecutando script de instalación de bspwm..."
            bash /tmp/arch-scripts/scripts/arch-install-2-bspwm.sh
            echo "Copiando dotfiles de bspwm..."
            cp -r /tmp/arch-scripts/bspwm /home/$USERNAME/.config/bspwm
            chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/bspwm
            break
            ;;
        xmonad)
            echo "Ejecutando script de instalación de xmonad..."
            echo "Clonando dotfiles de xmonad..."
            git clone https://github.com/kio-grnd/Arch.git /tmp/arch-scripts
            echo "Copiando dotfiles de xmonad..."
            cp -r /tmp/arch-scripts/xmonad /home/$USERNAME/.config/xmonad
            chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/xmonad
            break
            ;;
        Salir)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida. Por favor, elige nuevamente."
            ;;
    esac
done
EOF

# Hacer el archivo ejecutable
chmod +x /mnt/setup_choice.sh

# Ejecutar chroot y ejecutar el archivo de configuración
arch-chroot /mnt /bin/bash /setup_choice.sh

# Limpiar
rm /mnt/setup_choice.sh

echo "Finalización de la instalación."
