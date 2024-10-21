#!/bin/bash

# Selecciona una imagen aleatoria de la carpeta ~/.config/backgrounds
WALLPAPER=$(find ~/.config/backgrounds/ -type f | shuf -n 1)

# Aplica la imagen seleccionada como fondo usando feh
feh --bg-scale "$WALLPAPER"