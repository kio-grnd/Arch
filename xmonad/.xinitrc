# Configuración del teclado
setxkbmap es

# Iniciar xbindkeys
xbindkeys &

# Activar NumLock
numlockx on &

# nVIDIA fix-tearing
# ~/.local/bin/nvidia-fix-tearing.sh &

# Para mostrar un cursor por defecto
# xsetroot -cursor_name left_ptr &
xsetroot -cursor_name left_ptr &
# Iniciar xmonad
exec xmonad
