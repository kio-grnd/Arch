#
# ~/.xinitrc
#
# Ejecutado por startx (inicia tu gestor de ventanas desde aquí)

# Configuración del teclado
setxkbmap es

# Iniciar xbindkeys para gestionar atajos de teclado
xbindkeys &

# Cargar configuraciones gráficas de X11 con xrdb y .Xresources
xrdb -merge ~/.Xresources &

# Activar NumLock al inicio
numlockx on &

# Iniciar Picom para efectos de composición
# picom &

# (Opcional) Corregir el tearing en nVIDIA
# ~/.local/bin/nvidia-fix-tearing.sh &

# Iniciar Polybar
polybar &

# Establecer el cursor por defecto
xsetroot -cursor_name left_ptr &

# Iniciar xmonad como gestor de ventanas
exec xmonad
