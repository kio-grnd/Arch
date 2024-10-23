#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

# Configuración del teclado
setxkbmap es

# Iniciar xbindkeys
xbindkeys &

# Cargar configuraciones gráficas de X11 con xrdb y .Xresources
xrdb -merge ~/.Xresources

# Activar NumLock
numlockx on &

picom &

# nVIDIA fix-tearing
# ~/.local/bin/nvidia-fix-tearing.sh &

# Iniciar Polybar
polybar &


# Para mostrar un cursor por defecto
# xsetroot -cursor_name left_ptr &
xsetroot -cursor_name left_ptr &
# Iniciar xmonad
exec xmonad
