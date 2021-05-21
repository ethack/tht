exists () {
	#type $1 &> /dev/null
  command -v $1 >/dev/null 2>&1
}

PERSISTENT="/usr/local/share/zsh/"
mkdir -p "$PERSISTENT"

autoload -U colors && colors
PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~ %{$reset_color%}
$ "

if exists vim; then
  export EDITOR=vim
fi
if exists pspg; then
  export PAGER=pspg
fi
export TMPDIR=/tmp

# set history size
export HISTSIZE=10000
# save history after logout
export SAVEHIST=10000
# history file
export HISTFILE=$PERSISTENT/.zhistory
# append into history file
setopt APPEND_HISTORY
# save only one command if 2 common are same and consistent
setopt HIST_IGNORE_DUPS
# add timestamp for each entry
setopt EXTENDED_HISTORY

## Specific Tool Setup ##

if exists broot && [ -f /root/.config/broot/launcher/bash/br ]; then
  source /root/.config/broot/launcher/bash/br
  alias br='br -sdp'
fi

if exists exa; then
  if [ -f "$HOME/.local/share/fonts/Regular/Hack Regular Nerd Font Complete.ttf" ]; then
    alias ls="exa --classify --header --group --icons"
  else
    alias ls="exa --classify --header --group"
  fi
  alias lt='ls --long --tree --level 3'
else
  alias ls="ls --human-readable --classify --group-directories-first --color=auto"
fi

if exists fzf; then
  export FZF_HISTORY_DIR="$PERSISTENT/fzf"
  mkdir -p "$FZF_HISTORY_DIR"
  # set preview window layout; mainly for "interactively"
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview-window=down:90%"
  # colorize output; may consider disabling for performance reasons https://github.com/junegunn/fzf#performance
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --ansi"

  if exists fd; then
    # https://github.com/sharkdp/fd#using-fd-with-fzf
    export FZF_DEFAULT_COMMAND="fd --type file --hidden --follow --exclude '.git' --color=always"
  fi

  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

if exists zannotate; then 
  alias zannotate="zannotate --geoasn-database /usr/share/GeoIP/GeoLite2-ASN.mmdb --geoip2-database /usr/share/GeoIP/GeoLite2-Country.mmdb"
  alias za="zannotate"
fi

if exists zoxide; then
  export _ZO_DATA_DIR="$PERSISTENT/zoxide"
  mkdir -p "$_ZO_DATA_DIR"
  eval "$(zoxide init zsh)"
  # remove conflict
  __zoxide_unset 'zq'

  alias g='z'
fi

## General Aliases ##
alias history="history 1"  # show all entries by default
alias l='ls'
alias ll='ls -l'
alias la='ls -la'
alias ..='cd ..'
alias ...='cd ../..'
alias mv='mv -i'
alias mb='mv'              # common typo
alias mkdir="mkdir -p"     # create parent directories by default
alias df="df -h --total"
alias dud="du -h -d 1 --total"
alias digs="dig +short"
alias less="less -S"       # side-scrolling by default

# note: set stdin to /dev/null to prevent skim from hanging when running a command that reads stdin
alias live='sk --layout=reverse --no-sort --ansi --interactive --print-cmd --cmd-prompt="$ " --show-cmd-error --cmd="0</dev/null {}"'

## ZSH Setup; must be last ##

# these are supposed to make the g command work. TODO
autoload -Uz compinit
compinit
# autocompletion with an arrow-key driven interface
zstyle ':completion:*' menu select
