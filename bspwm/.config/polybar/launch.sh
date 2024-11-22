#!/bin/bash

# Termina cualquier instancia existente de Polybar
killall polybar

# Inicia Polybar con la configuración definida en ~/.config/polybar/config.ini
polybar example &  # Reemplaza 'example' con el nombre de tu barra si es diferente
