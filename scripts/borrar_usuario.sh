#!/bin/bash

# Solicitar el nombre de usuario que se desea eliminar
read -p "Ingrese el nombre de usuario que desea eliminar: " usuario

# Confirmar que el usuario desea continuar
read -p "¿Está seguro de que desea eliminar el usuario '$usuario' y su directorio personal? (s/n): " confirmacion

if [[ "$confirmacion" =~ ^[Ss]$ ]]; then
    # Borrar el usuario y su directorio personal
    userdel -r "$usuario"

    if [[ $? -eq 0 ]]; then
        echo "Usuario '$usuario' y su directorio personal han sido eliminados exitosamente."
    else
        echo "Ocurrió un error al intentar eliminar el usuario '$usuario'."
    fi
else
    echo "Operación cancelada. No se eliminó el usuario."
fi
