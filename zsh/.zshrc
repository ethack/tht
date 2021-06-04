exists () {
	#type $1 &> /dev/null
  command -v $1 >/dev/null 2>&1
}

PERSISTENT="/usr/local/share/zsh/"
mkdir -p "$PERSISTENT"

autoload -U colors && colors
PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~ %{$reset_color%}
$ "

if ! exists vim && exists vi; then
  alias vim=vi
fi

if exists vim; then
  export EDITOR=vim
fi
if exists pspg; then
  export PAGER="pspg --quit-if-one-screen"
fi
export TMPDIR=/tmp
export SHELL=/usr/bin/zsh

# set history size
export HISTSIZE=10000
# save history after logout
export SAVEHIST=10000
# history file
export HISTFILE=$PERSISTENT/.zhistory
# append into history file
setopt INC_APPEND_HISTORY
# save only one command if 2 common are same and consistent
setopt HIST_IGNORE_DUPS
# add timestamp for each entry; note: don't do this so it can double as fzf history
#setopt EXTENDED_HISTORY

## Specific Tool Setup ##

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
  # colorize output; may consider disabling for performance reasons https://github.com/junegunn/fzf#performance
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --ansi"

  if exists fd; then
    # https://github.com/sharkdp/fd#using-fd-with-fzf
    export FZF_DEFAULT_COMMAND="fd --type file --hidden --follow --exclude '.git' --color=always"
  fi

  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

if exists navi; then
  eval "$(navi widget zsh)"
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

  function g() {
    z "$@" && ls
  }
fi

## General Aliases ##
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

# set stdin to /dev/null to prevent skim from hanging when running a command that reads stdin
alias live_skim='sk --layout=reverse --no-sort --ansi --interactive --print-cmd --cmd-prompt="$ " --show-cmd-error --cmd="0</dev/null FILTER_NO_STDIN=1 {}"'
# BUG: Can't use single quotes in the live view.
# BUG: Can't use zsh aliases or functions.
alias live_fzf="\
  FZF_DEFAULT_COMMAND=: \
  fzf --ansi \
    --no-sort \
    --disabled \
    --print-query \
    --no-info \
    --no-bold \
    --preview \"0</dev/null FILTER_NO_STDIN=1 '{q}'\" \
    --preview-window 'down:99%' \
    --prompt '$ ' \
    --bind 'change:reload:sleep 0.3'"
alias live=live_skim

## Zeek Aliases/Functions ##
function zeek2csv() { zq -f csv ${@:-} - }
function zeek2tsv() { 
  if [  -n "$1" ]; then 
    zq -f zeek $@ - | sed -e '0,/^#fields\t/s///' | grep -v '^#'
  else
    # doing this without zq is much faster and leaves the header row intact
    sed -e '0,/^#fields\t/s///' | grep -v '^#'
  fi
}
function zeek2zeek() { zq -f zeek ${@:-} - }
function zeek2json() { zq -f ndjson ${@:-} - }
function zeek2table() { zq -f table ${@:-} - }
alias z2c=zeek2csv
alias z2t=zeek2tsv
alias z2z=zeek2zeek
alias z2j=zeek2json
alias z2table=zeek2table

## ZSH Setup; must be last ##
autoload -Uz compinit
compinit
# autocompletion with an arrow-key driven interface
zstyle ':completion:*' menu select
