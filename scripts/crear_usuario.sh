#!/bin/bash

# Solicitar el nombre de usuario
read -p "Ingrese el nombre de usuario que desea crear: " usuario

# Solicitar el nombre completo
read -p "Ingrese el nombre completo del usuario: " nombre_completo

# Crear el usuario y establecer su grupo y shell
if useradd -m -g users -G wheel,audio,lp,optical,storage,video,games,power,scanner -s /bin/bash "$usuario"; then
    echo "Usuario '$usuario' creado."
else
    echo "Error: No se pudo crear el usuario '$usuario'." >&2
    exit 1
fi

# Establecer el nombre completo del usuario
if usermod -c "$nombre_completo" "$usuario"; then
    echo "Nombre completo del usuario '$usuario' establecido."
else
    echo "Error: No se pudo establecer el nombre completo." >&2
    exit 1
fi

# Establecer la contraseña del usuario
if passwd "$usuario"; then
    echo "Contraseña establecida."
else
    echo "Error: No se pudo establecer la contraseña para '$usuario'." >&2
    exit 1
fi

echo "Usuario '$usuario' creado exitosamente con el nombre completo '$nombre_completo'."
