# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

exists () {
  command -v $1 >/dev/null 2>&1
  #(( $+commands[$1] )) # this is zsh
}

PERSISTENT="/usr/local/share/zsh"
mkdir -p "$PERSISTENT"

autoload -U colors && colors
PS1="%{$fg[red]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~ %{$reset_color%}
$ "

export TMPDIR=/tmp
export SHELL=/usr/bin/zsh

## History ##

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

if [ -f "$HOME/.zinit/zinit.zsh" ]; then
  source ~/.zinit/zinit.zsh
  # install zsh plugins with zinit turbo mode
  zinit wait lucid depth=1 for \
    https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
      zdharma/fast-syntax-highlighting \
    blockf \
      zsh-users/zsh-completions \
    svn \
      OMZ::plugins/history-substring-search \
    atload"!_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions
  # powerlevel10k theme
  # zinit light-mode depth=1 for \
  #   romkatv/powerlevel10k
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

if exists dog; then
  alias dig=dog
fi

## General Aliases ##
#setopt complete_aliases # Unintuitively, disabling this option allows tab completion of alias arguments but does not complete the alias itself

alias reload="source ~/.zshrc"

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
alias digs="dig +short"
alias less="less -S"       # side-scrolling by default
alias history="history 0"  # make history show all entries by default
alias h="head"
alias t="tail -f"

alias distinct="sort | uniq"
alias countdistinct="sort | uniq | wc -l"
# most frequent occurrence (show all by default)
function mfo() {
  sort | uniq -c | sort -nr | head --lines=${1:--0}
}
# least frequent occurrence (show all by default)
function lfo() {
  sort | uniq -c | sort -n | head --lines=${1:--0}
}
# split by domain level (default 2)
function domain() {
  rev | cut -d. -f1-${1:-2} | rev
}

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

## ZSH Setup; must be last ##
autoload -Uz compinit
compinit
# autocompletion with an arrow-key driven interface
zstyle ':completion:*' menu select

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh