# Configuración del teclado
setxkbmap es 

# Iniciar xbindkeys
xbindkeys &

# Activar NumLock
numlockx on &

# Para mostrar un cursor por defecto
xsetroot -cursor_name left_ptr &

# Para sonido con PipeWire
# pamixer &

# nVIDIA fix-tearing
# ~/scripts/nvidia-fix-tearing.sh &

# Lanzar sxhkd para atajos de teclado
sxhkd &

# Iniciar xmonad
# exec xmonad

# Iniciar bspwm
exec bspwm
