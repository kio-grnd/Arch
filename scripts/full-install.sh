#!/bin/bash

# -----------------------------
# Variables generales del script
# -----------------------------
# Asegúrate de definir las particiones y el nombre de usuario aquí
# ROOT_PARTITION="/dev/sda1"  # Cambia esto según tu configuración
# SWAP_PARTITION="/dev/sda2"  # Cambia esto según tu configuración
# USERNAME="tu_usuario"       # Cambia esto por el nombre de usuario que vayas a usar

# -----------------------------
# Particionamiento (si es necesario)
# -----------------------------
# Formateo y montaje de las particiones (descomentar si se desea habilitar)
# mkfs.ext4 $ROOT_PARTITION
# mkswap $SWAP_PARTITION
# swapon $SWAP_PARTITION
# mount $ROOT_PARTITION /mnt

# -----------------------------
# Instalación base del sistema
# -----------------------------
pacstrap /mnt base linux linux-firmware vim nano git

# Generar el archivo fstab con las particiones montadas
genfstab -U /mnt >> /mnt/etc/fstab

# -----------------------------
# Configuración del reloj (hora local)
# -----------------------------
echo "Configurando el reloj del sistema a la hora local..."
arch-chroot /mnt hwclock --systohc --localtime

# -----------------------------
# Configuración en chroot
# -----------------------------
echo "Instalación base completada. Ahora ejecutando 'arch-chroot /mnt'."

# Crear un archivo de configuración temporal
cat << EOF > /mnt/setup_choice.sh
#!/bin/bash

# Asegurarse de que el repositorio solo se clone una vez
echo "Clonando el repositorio..."
git clone https://github.com/vetealdiablo/Arch /tmp/arch-scripts

# Elegir entorno de escritorio
echo -e "\n¿Qué entorno de escritorio deseas instalar?"
select option in "i3" "bspwm" "xmonad" "Salir"; do
    case \$option in
        i3)
            echo "Ejecutando script de instalación de i3..."
            bash /tmp/arch-scripts/scripts/arch-install-2-i3.sh
            break
            ;;
        bspwm)
            echo "Ejecutando script de instalación de bspwm..."
            bash /tmp/arch-scripts/scripts/arch-install-2-bspwm.sh
            break
            ;;
        xmonad)
            echo "Ejecutando script de instalación de xmonad..."
            bash /tmp/arch-scripts/scripts/arch-install-2-xmonad.sh
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
