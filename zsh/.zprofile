#!/bin/zsh

##
# Zsh runs .zprofile once for each new login shell, after .zshenv, but before .zshrc. Everything
# here should be exported, so it's available in new shells started from the login shell.
#
# NOTE: In VTE-based terminals, such as Gnome Terminal & Tilix, you have to explicitly set in each
# profile that a new window/tab opens a login shell. Otherwise, .zprofile will not get sourced!
#

# We need to set $path here and not in .zshenv, else /etc/zprofile will override it.
export -U PATH path FPATH fpath MANPATH manpath  # Remove duplicates.
export -TU INFOPATH infopath
export HOME=/Users/hubs
export XDG_CONFIG_HOME  # Value is set in .zshenv
export XDG_DATA_HOME=~/.local/share
export GRADLE_USER_HOME=$XDG_CONFIG_HOME/gradle

export HOMEBREW_BAT=1
export HOMEBREW_COLOR=1
path=( /usr/local/Homebrew/bin(N) $path[@] )
eval "$( brew shellenv )"

export PYENV_ROOT="$HOME/.pyenv"
path=( $PYENV_ROOT/bin $path[@] )
eval "$(pyenv init --path)"

export PIPX_BIN_DIR=~/.local/bin

export ANDROID_SDK_ROOT=$HOMEBREW_PREFIX/share/android-commandlinetools

# (N) deletes the item if it doesn't exist.
path=(
  $PIPX_BIN_DIR(N)
  $PYENV_ROOT/{bin,shims}(N)
  $ANDROID_SDK_ROOT/{emulator,platform-tools}(N)
  $HOMEBREW_PREFIX/opt/{openjdk,pipx,llvm,mariadb@10.3,ncurses,tomcat@9}/bin(N)
  /opt/local/{bin,sbin}(N)
  /Library/Developer/CommandLineTools/usr/{bin,share}(N) # MacPorts
  $path[@]
  .
)

export CATALINA_HOME=$HOMEBREW_PREFIX/opt/tomcat@9/libexec
export CATALINA_BASE=~/Tomcat9

export LANG=en_US.UTF-8
export VISUAL="/usr/local/bin/mate -w"  
export EDITOR="/usr/local/bin/nano"
export READNULLCMD=bat
export PAGER="/usr/local/bin/less"
export MANPAGER='bat -l man'; [[ $OSTYPE == darwin* ]] && MANPAGER="col -bpx | $MANPAGER"
export LESS='-FiMr -j.5 --incsearch'
export LESSHISTFILE=$XDG_DATA_HOME/less/lesshst
export QUOTING_STYLE=escape # Used by GNU ls

if [[ $OSTYPE == darwin*   ]]; then
  export SHELL_SESSIONS_DISABLE=1
  export JAVA_HOME=$( /usr/libexec/java_home )
fi
if [[ $OSTYPE == linux-gnu ]]; then
  export DEBIAN_PREVENT_KEYBOARD_CHANGES=1
  fpath+=( $HOMEBREW_PREFIX/share/zsh/site-functions )
fi
[[ $VENDOR == ubuntu ]] &&
    export skip_global_compinit=1
