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

# export PATH=$PATH:/usr/local/bundle/bin

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

if exists zeek-pdns; then
  alias pdns=zeek-pdns
  alias pdi="zeek-pdns index"
  alias pdli="zeek-pdns like individual"
  alias pdlt="zeek-pdns like tuples"
  alias pdfi="zeek-pdns find individual"
  alias pdft="zeek-pdns find tuples"
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

if exists asn; then
  # disable traceroute
  alias asn='asn -n'
fi

# QSV settings
# https://github.com/jqnatividad/qsv#environment-variables
export QSV_SNIFF_DELIMITER=1
export QSV_NO_UPDATE=1
export QSV_PREFER_DMY=1
export QSV_PROGRESSBAR=1
# export QSV_COMMENT_CHAR=#
# export QSV_DEFAULT_DELIMITER=$'\t'

if exists navi; then
  eval "$(navi widget zsh)"
  function cht() { navi --print --cheatsh "$*" }
fi

function cheat() {
  (cd /root/.local/share/navi/cheats/;
  fd --type file --extension cheat --exec echo {/.} \
    | fzf --query="$1" --select-1 --exit-0 \
    | xargs -I {} bat -l bash {}.cheat
  )
}

if exists zannotate; then 
  alias zannotate="zannotate --geoasn-database /usr/share/GeoIP/GeoLite2-ASN.mmdb --geoip2-database /usr/share/GeoIP/GeoLite2-Country.mmdb"
  alias za="zannotate"
fi

if exists zoxide; then
  export _ZO_DATA_DIR="$PERSISTENT/zoxide"
  mkdir -p "$_ZO_DATA_DIR"
  eval "$(zoxide init zsh)"

  function g() {
    case "$*" in
    # environment specific paths
    today)
      __zoxide_z "/host/opt/zeek/remotelogs/COMBINED__0000/$(date +%F)"
    ;;
    yesterday)
      __zoxide_z "/host/opt/zeek/remotelogs/COMBINED__0000/$(date --date yesterday +%F)"
    ;;
    *)
      # if z fails to find a directory, then try again in the /host/ filesystem
      # if both fail then print the error message from the original command instead
      {__zoxide_z "$*" 2>/dev/null && ls} || \
      {__zoxide_z "/host/$*" 2>/dev/null && ls} || \
      __zoxide_z "$*"
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
function zeek2json() { zq -f json ${@:-} - }
alias z2c=zeek2csv
alias z2t=zeek2tsv
alias z2z=zeek2zeek
alias z2j=zeek2json
function z2() {
  format="$1"
  shift
  type="$1"
  # if argument is a file, extract the type from the filename
  if [[ -f $type ]]; then
    type=$(basename "$1" | sed -E 's/^(.*?)(\.|_\d)/\1/')
  fi
  zq "put _path:='$type'" "$@" | zq -f $format -I /root/.config/zq/shaper.zed -
}

# BUG: this doesn't work for things like z head
# unalias z
function z() {
  args=()
  # if there's an argument with a space in it, prepend a |
  # https://github.com/brimdata/zed/issues/2584
  # https://github.com/brimdata/zed/issues/1059
  for arg in "$@"; do
    # add the flags that always trip me up
    if [[ "$arg" == "--help" ]] || [[ "$arg" == "help" ]]; then
      args+=("-h")
    elif [[ "$arg" == "-v" ]] || [[ "$arg" == "version" ]]; then
      args+=("-version")
    # BUG: z -f zng (or any file format) will trigger this
    # check if the argument contains a space or only letters, doesn't start with a |, and isn't a file
    elif ([[ "$arg" == *" "* ]] || [[ "$arg" =~ ^[[:alpha:]]+$ ]]) && [[ "$arg" != "|"* ]] && [[ ! -f "$arg" ]]; then
      args+=("| $arg")
    else
      args+=("$arg")
    fi
  done

  # add - if missing a path element and stdin is redirected
  if [[ ! -t 0 ]] && [[ ${args[-1]} != "-" ]] && [[ ! -e ${args[-1]} ]]; then
    args+=("-")
  fi
  # TODO: set _path from filename if it doesn't exist

  # echo zq -I /root/.config/zq/shaper.zed "${args[@]}"
  zq -I /root/.config/zq/shaper.zed "${args[@]}"
}

# convert timestamps to human-readable by default
alias zeek-cut="zeek-cut -U '%FT%TZ'"

# customize autosuggest
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,underline"
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history)
# activate plugins
if [[ -f "$XDG_CONFIG_HOME/sheldon/source.zsh" ]]; then
  eval "$(cat "$XDG_CONFIG_HOME/sheldon/source.zsh")"
fi