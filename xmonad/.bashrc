# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Put your fun stuff here.
export PATH="$HOME/.local/bin:$PATH"

# Alias para mostrar la hora
alias hora='~/.local/bin/hora.sh'

# Alias para mostrar la hora con otra frase (Nota: los alias no pueden tener espacios)
alias que_hora_es='~/.local/bin/hora.sh'

# Alias para limpiar espacio en disco
alias espacio='~/.local/bin/espacio_disco.sh'

# Alias para pkg de FreeBSD
alias pkg='sudo pacman'

# Actualizar los repositorios y los paquetes instalados
alias pkg-update='sudo pacman -Syu'

# Instalar un paquete
alias pkg-install='sudo pacman -S'

# Desinstalar un paquete
alias pkg-remove='sudo pacman -R'

# Buscar un paquete
alias pkg-search='pacman -Ss'

# Mostrar información sobre un paquete
alias pkg-info='pacman -Qi'

# Limpiar paquetes no necesarios
alias pkg-clean='sudo pacman -Rns $(pacman -Qdtq)'

# Listar paquetes instalados
alias pkg-list='pacman -Q'

cowfortune() {
    cow=$(cowsay -l | tr -d ' ' | tr '\n' ' ' | awk '{print $1}')
    fortune | cowsay -f "$cow" | lolcat --spread 1.0
}


export PATH="$HOME/.local/bin:$PATH"

