#!/bin/bash

# -----------------------------
# Variables generales del script
# -----------------------------
# read -p "Introduce el nombre del host: " HOSTNAME
# read -p "Introduce tu nombre de usuario: " USERNAME

# -----------------------------
# Particionamiento
# -----------------------------
read -p "Introduce la partición raíz (ejemplo: /dev/sda1): " ROOT_PARTITION
read -p "Introduce la partición swap (ejemplo: /dev/sda2): " SWAP_PARTITION

# Formateo y montaje de las particiones (descomentar si se desea habilitar)
# mkfs.ext4 $ROOT_PARTITION
# mkswap $SWAP_PARTITION
# swapon $SWAP_PARTITION
# mount $ROOT_PARTITION /mnt

# -----------------------------
# Instalación base del sistema
# -----------------------------
pacstrap /mnt base linux linux-firmware vim nano

genfstab -U /mnt >> /mnt/etc/fstab

# -----------------------------
# Configuración en chroot
# -----------------------------
echo "Instalación base completada. Ahora ejecutando 'arch-chroot /mnt'."

# Crear un archivo de configuración temporal
cat << EOF > /mnt/setup_choice.txt
# Elegir entorno de escritorio
echo -e "\n¿Qué entorno de escritorio deseas instalar?"
select option in "i3" "bspwm" "Salir"; do
    case \$option in
        i3)
            echo "Ejecutando script de instalación de i3..."
            bash /path/to/arch-install-2-i3.sh
            break
            ;;
        bspwm)
            echo "Ejecutando script de instalación de bspwm..."
            bash /path/to/arch-install-2-bspwm.sh
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

# Ejecutar chroot y leer el archivo de configuración
arch-chroot /mnt /bin/bash /setup_choice.txt

# Limpiar
rm /mnt/setup_choice.txt

echo "Finalización de la instalación."
