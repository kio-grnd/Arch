#!/bin/bash

# Directorio home del usuario
home_dir="$HOME"

# Buscar todos los archivos en el directorio home
# y dar permisos de ejecución a los archivos que son ejecutables (no tienen permisos de ejecución).
find "$home_dir" -type f ! -executable -exec chmod +x {} \;

# Mostrar un mensaje al finalizar
echo "Se han dado permisos de ejecución a todos los archivos encontrados en $home_dir que no los tenían."
