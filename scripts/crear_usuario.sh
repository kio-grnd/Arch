#!/bin/bash

# Solicitar el nombre de usuario
read -p "Ingrese el nombre de usuario que desea crear: " usuario

# Solicitar el nombre completo
read -p "Ingrese el nombre completo del usuario: " nombre_completo

# Crear el usuario y establecer su grupo y shell
sudo useradd -m -g users -G wheel,audio,lp,optical,storage,video,games,power,scanner -s /bin/bash "$usuario"

# Establecer el nombre completo del usuario
sudo usermod -c "$nombre_completo" "$usuario"

# Establecer la contraseña del usuario
sudo passwd "$usuario"

echo "Usuario '$usuario' creado exitosamente con el nombre completo '$nombre_completo'."
