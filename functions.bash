#!/usr/bin/env bash
#

# user defined aliases .bash
#

export PROMPT_COMMAND="ps1;$PROMPT_COMMAND"

BLACK="\[\033[1;30m\]"
RED="\[\033[1;31m\]"
GREEN="\[\033[1;32m\]"
YELLOW="\[\033[1;33m\]"
BLUE="\[\033[1;34m\]"
PURPLE="\[\033[1;35m" 
CYAN="\[\033[1;36m\]"
WHITE="\[\033[1;37m\]"
NOCOLOR="\[\033[00m\]"

function parse_git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

function parse_git_branch_colour {
  br=$(parse_git_branch)
  if [ -z "$br" ]; then
    return
  elif [ "$br" == "master" ]; then
    echo " $BLUE($RED"$br"$BLUE $(parse_git_dirty))"
  else
    echo " $BLUE($YELLOW"$br"$BLUE $(parse_git_dirty))"
  fi
}

function parse_git_dirty {

  local large_repos=~/.bash_git_large_repos
  local unchanged="$GREEN✔$NOCOLOR"
  local changed="$RED✗$NOCOLOR"
  local sts_skip="$RED❔$YELLOW❓$GREEN❓$NOCOLOR"

  # check for large repo (fastest)
  [ -n "$GIT_LARGE_REPO" ] && echo $sts_skip && return

  # (slower) check for large repo in filenames of all large repos
  /bin/grep -qw "$PWD$" $large_repos 2>/dev/null
  if [ $? -eq 0 ]; then 
    echo $sts_skip
  else
    # not in list of large repos, run a one time check for this being a large repo
    if [ $OS == "FreeBSD" ]; then
      sts=$(/usr/bin/time -p git status --porcelain 2>&1)
      echo -e '\b'
    else
      sts=$(/usr/bin/time -f "%E" git status --porcelain 2>&1)
      if [ $(echo "$sts"|wc -l) -eq 1 ]; then
        echo $unchanged
      else
      # do we need to add it to the list of large repos?
        if [ $(echo "$sts"|tail -1 |cut -d: -f2|cut -d. -f1) -gt 1 ]; then 
          echo "$PWD" >> $large_repos
          export GIT_LARGE_REPO="$PWD"
          echo $sts_skip && return
        fi
        # no then 
        echo "$sts"|head -1|grep -Ee '^[0-9]:[0-9][0-9].[0-9][0-9]$' 2>&1 >/dev/null
        if [ $? -eq 0 ]; then
          echo $unchanged 
        fi
          echo $changed
        fi
    fi
  fi
}

# Edit your current day's todo list. 
function todo(){ 
  ${EDITOR:-/usr/local/bin/vim} + ~/$(date +todolist-%Y%m%d); 
}
  
function ps1 {
  PS1="$GREEN${OSRV}$BLUE:\w$(parse_git_branch_colour)$NOCOLOR$ "
  PROMPT_COMMAND="ps1"
}

function psh {
  PS1="$BLUE\h:\W$(parse_git_branch_colour)$NOCOLOR$ "
  PROMPT_COMMAND="psh"
}

function pss {
  PS1="$BLUE\w$(parse_git_branch_colour)$NOCOLOR$ "
  PROMPT_COMMAND="pss"
}

function anc {
  alias ls='lsn'
  alias tree='tree -n'
  alias grep='grep --color=none -i'
}

function dpkg-list {
dpkg-query --list|awk -F' ' '{printf("%s\t%-32s\t",$1,substr($2,0,40));$1=$2=$3=$4=""; print $0}'
}

function pkg_locate {
  [ -z "$1" ] && echo "Usage: pkg_locate name" && return
  ports "$1"
}

function ports {
  [ -z "$1" ] && echo "Usage: ports name" && return
  pushd /usr/ports > /dev/null
  echo */*|tr ' ' '\n'|grep $1
  popd  > /dev/null
}


# vim:nospell:ft=sh:
