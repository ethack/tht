export XDG_CONFIG_HOME="$HOME/.config"

exists () {
  command -v $1 >/dev/null 2>&1
  #(( $+commands[$1] )) # this is zsh
}

# display tip of the day
if exists random-tip; then random-tip; fi

# show prompt right away
autoload -U colors && colors
PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~ %{$reset_color%}
$ "

## Misc Settings ##

# autocompletion with an arrow-key driven interface
zstyle ':completion:*' menu select

# fix home and end keys in some terminals (e.g. PuTTY, MobaXterm)
bindkey  "^[[1~"   beginning-of-line
bindkey  "^[[4~"   end-of-line
# MobaXterm
bindkey  "^[[H"    beginning-of-line
bindkey  "^[[F"    end-of-line

export PERSISTENT="/usr/local/share/zsh"
mkdir -p "$PERSISTENT"

export TMPDIR=/tmp
export SHELL=/usr/bin/zsh

# change directories by typing the name of the directory
setopt AUTO_CD

# restore OLDPWD value
touch "$PERSISTENT/.oldpwd"
source "$PERSISTENT/.oldpwd"

## History Settings ##

# set history size
export HISTSIZE=10000
# save history after logout
export SAVEHIST=10000
# history file
export HISTFILE=$PERSISTENT/.zhistory
# append into history file
setopt INC_APPEND_HISTORY
# save only one command if 2 common are same and consistent
# setopt HIST_IGNORE_DUPS
# add timestamp for each entry
setopt EXTENDED_HISTORY

## Specific Tool Setup ##

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

if exists bro-pdns; then
  alias pdns=bro-pdns
  alias pdi="bro-pdns index"
  alias pdli="bro-pdns like individual"
  alias pdlt="bro-pdns like tuples"
  alias pdfi="bro-pdns find individual"
  alias pdft="bro-pdns find tuples"
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

if exists mtr; then
  alias traceroute=mtr
  alias tracert=mtr
fi

if exists navi; then
  eval "$(navi widget zsh)"
  function cht() { navi --print --cheatsh "$*" }
fi

if exists tldr; then
  export TEALDEER_CACHE_DIR="$PERSISTENT/tealdear"
  mkdir -p "$TEALDEER_CACHE_DIR"
fi

if exists zannotate; then 
  alias zannotate="zannotate --geoasn-database /usr/share/GeoIP/GeoLite2-ASN.mmdb --geoip2-database /usr/share/GeoIP/GeoLite2-Country.mmdb"
  alias za="zannotate"
fi

if exists zoxide; then
  export _ZO_DATA_DIR="$PERSISTENT/zoxide"
  mkdir -p "$_ZO_DATA_DIR"
  eval "$(zoxide init zsh)"
  # remove alias conflict
  __zoxide_unset 'zq'

  function g() {
    case "$1" in
    #-) cd - && ls ;; # hard-code - to be previous cwd # not needed
    *) 
      # if z fails to find a directory, then try again in the /host/ filesystem
      # if both fail then print the error message from the original command instead
      {z "$*" 2>/dev/null && ls} || \
      {z "/host/$*" 2>/dev/null && ls} || \
      z "$*"
    ;;
    esac
  }
fi

if ! exists vim && exists vi; then
  alias vim=vi
fi

if exists vim; then
  export EDITOR=vim
fi

if exists dog && ! exists dig; then
  alias dig=dog
fi

## General Aliases ##
#setopt complete_aliases # Unintuitively, disabling this option allows tab completion of alias arguments but does not complete the alias itself

alias reload="source ~/.zshrc"

alias version='cat /etc/tht-release'
alias tht="echo 'You are currently running THT version $(cat /etc/tht-release | grep DATE | sd DATE= '')'"

alias l='ls'
alias ll='ls -l'
alias la='ls -la'
alias ..='cd ..'
alias ...='cd ../..'
alias mv='mv -i'
alias mb='mv -i'           # common typo
alias mkdir="mkdir -p"     # create parent directories by default
alias df="df -h --total"
alias dud="du -h -d 1 --total"
function duds() { du -h -d 1 --total "$@" | sort -h }
alias digs="dig +short"
alias less="less -S"       # side-scrolling by default
alias history="history 0"  # make history show all entries by default
alias h="head"
alias t="tail -f"

# other names people might use instead
alias cardinality=card
alias countdistinct=card
alias distinctcount=card
alias stackcount=mfo
alias shorttail=mfo
alias longtail=lfo
alias first='sort | head -n 1'
alias last='sort | tail -n 1'

alias cv="viewer csv"
alias tv="viewer tsv"
alias zv="viewer zeek" 
# these print out tables instead of opening a viewer
function cvt() { viewer csv "$@" | cat }
function tvt() { viewer tsv "$@" | cat }
function zvt() { viewer zeek "$@" | cat }

## Zeek Aliases/Functions ##
function zeek2csv() { zq -f csv ${@:-} - }
function zeek2tsv() { 
  if [  -n "$1" ]; then 
    zq -f zeek $@ - | sed -e '0,/^#fields\t/s///' | grep -v '^#'
  else
    # doing this without zq is much faster and leaves the header row intact
    # note: unlike the others, this only works for Zeek TSV input
    sed -e '0,/^#fields\t/s///' | grep -v '^#'
  fi
}
function zeek2zeek() { zq -f zeek ${@:-} - }
function zeek2json() { zq -f ndjson ${@:-} - }
alias z2c=zeek2csv
alias z2t=zeek2tsv
alias z2z=zeek2zeek
alias z2j=zeek2json

# convert timestamps to human-readable by default
alias zeek-cut="zeek-cut -U '%FT%TZ'"

# customize autosuggest
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history)
# activate plugins
if [[ -f "$XDG_CONFIG_HOME/sheldon/source.zsh" ]]; then
  eval "$(cat "$XDG_CONFIG_HOME/sheldon/source.zsh")"
fi