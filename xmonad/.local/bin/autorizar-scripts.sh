#!/bin/bash

# Directorio donde buscar los archivos .sh (tu home)
DIR="$HOME"

# Buscar archivos .sh y otorgar permisos de ejecución
echo "Buscando archivos .sh en $DIR ..."
find "$DIR" -type f -name "*.sh" | while read -r file; do
    if [ -x "$file" ]; then
        echo "El archivo '$file' ya tiene permisos de ejecución."
    else
        echo "Otorgando permisos de ejecución a '$file'..."
        chmod +x "$file"
    fi
done

echo "Proceso finalizado."
