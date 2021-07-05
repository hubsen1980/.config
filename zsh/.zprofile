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
export DEVELOPER_DIR=/Library/Developer
export GIT_EDITOR="mate --name 'Git Commit Message' -w -l 1"
export HOMEBREW_BAT=1
export HOMEBREW_COLOR=1
path=( /usr/local/Homebrew/bin(N) $path[@] )
eval "$( brew shellenv )"
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
export PYENV_ROOT="$HOME/.pyenv"
path=( $PYENV_ROOT/bin $path[@] )
eval "$(pyenv init --path)"

export PIPX_BIN_DIR=~/.local/bin

export ANDROID_SDK_ROOT=$HOMEBREW_PREFIX/share/android-commandlinetools

# (N) deletes the item if it doesn't exist.
path=(
  /usr/local/{bin,sbin}(N)
  /opt/local/{bin,sbin}(N)
  /opt/X11/{bin,share}(N)
  /bin/(N)
  /sbin/(N)
  $PIPX_BIN_DIR(N)
  $PYENV_ROOT/{bin,shims}(N)
  $ANDROID_SDK_ROOT/{emulator,platform-tools}(N)
  $HOMEBREW_PREFIX/opt/{apr,capnp,gmp,libev,mas,openjdk,readline,yarn-completion,apr-util,cmake,gnustep-make,libevent,mecab,openlda,rtmpdump,znapzend,asciinema,coreutils,google-sparsehash,libfido2,mecab-ipadic,openssh,ruby,zsh,autoconf,curl,gradle,libidn2,mpdecimal,openssl@1.1,six,zsh-async,automake,dash,gradle-completion,libmpc,mpfr,pcre,solidity,zsh-git-prompt,bash,docker,grep,libssh2,msgpack.pcre2,sqlite,zsh-vi-mode,bash-completion,fzf,groonga,libunistring,multimarkdown,perl,subversion,zshdb,bat,gcc,icu4c,libuv,mysql,pipx,tomcat@9,zstd,berkeley-db,gdbm,isl,libyaml,nano,pkg-config,typescript,bmake,gem-rake,jemalloc,llvm,ncurses,premake,utf8proc,boost,gem-rmate,ksh,lz4,nghttp2,protobuf,wget,brew-gem,gettext,ldns,m4,ninja,pyenv,xmake,brotli,gh,less,make,node,python@3.9,xz,c-ares,git,libcbor,mariadb@10.3,nvm,ragel,yarn}/{bin,share}((N)
  /Library/Developer/CommandLineTools/usr/{bin,share}(N) # MacPorts
  $path[@]
  .
)
export MANPATH="/opt/local/share/man:$MANPATH"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export DISPLAY=:0.0
export CATALINA_HOME=$HOMEBREW_PREFIX/opt/tomcat@9/libexec
export CATALINA_BASE=~/Tomcat9
export LANG=en_US.UTF-8
export VISUAL="/usr/local/bin/mate -w"  
export EDITOR="/usr/local/bin/nano"
export READNULLCMD=bat
export PAGER="/usr/local/bin/less"
export MANPAGER='bat -l man'
export MANPAGER="col -bpx | $MANPAGER"
export LESS='-FiMr -j.5 --incsearch'
export LESSHISTFILE=$XDG_DATA_HOME/less/lesshst
export QUOTING_STYLE=escape # Used by GNU ls
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"
if [[ $OSTYPE == darwin*   ]]; then
  export SHELL_SESSIONS_DISABLE=1
  export JAVA_HOME=$( /usr/libexec/java_home )
fi
if [[ $OSTYPE == darwin* ]]; then
  export DEBIAN_PREVENT_KEYBOARD_CHANGES=1
  fpath+=( $HOMEBREW_PREFIX/share/zsh/site-functions $HOME/.local $HOME/.local/zsh-completions/src  );
fi
export skip_global_compinit=1
export CPPFLAGS="-I/usr/local/opt/openjdk/include"
[[ -e ~/.profile ]]; 
emulate sh -c 'source ~/.profile' 
export PS1="%10F%m%f:%11F%1~%f \$ "
export CPPFLAGS="-I/usr/local/opt/openjdk/include"
if [ -r ~/.zshrc ]; then echo 'export GPG_TTY=$(tty)' >> ~/.zshrc; \
	else echo 'export GPG_TTY=$(tty)' >> ~/.zprofile; 
fi

