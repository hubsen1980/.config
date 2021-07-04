#!/usr/local/bin/gmake -f

upstream = https://github.com/hubsen1980/.config.git
SHELL = /usr/local/bin/zsh

# Include only those formulas that we want on all machines.
formulas := asciinema bat less nano
ifeq (linux-gnu,$(shell print $$OSTYPE))
formulas += grep
else
formulas += bash coreutils
endif

taps := autoupdate core services
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
taps += cask cask-fonts cask-versions
casks = karabiner-elements rectangle adoptopenjdk8 visual-studio-code \
	font-material-icons font-montserrat font-open-sans font-roboto font-ubuntu
endif

executables = aureliojargas/clitest ekalinin/github-markdown-toc

zshenv = ~/.zshenv
sshconfig = ~/.ssh/config
dotfiles := $(zshenv) $(sshconfig)
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
vscodesettings = ~/Library/ApplicationSupport/Code/User/settings.json
vscodekeybindings = ~/Library/ApplicationSupport/Code/User/keybindings.json
dotfiles += $(vscodesettings) $(vscodekeybindings)
endif

prefix = /usr/local
ifeq (linux-gnu,$(shell print $$OSTYPE))
exec_prefix = /usr/local/Homebrew
else
exec_prefix = $(prefix)
endif
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir = $(datarootdir)

BASH = /usr/local/bin/bash
CURL = /usr/bin/curl
OSASCRIPT = /usr/bin/osascript
DSCL = /usr/bin/dscl
DCONF = /usr/bin/dconf
GETENT = /usr/bin/getent
GIO = /usr/bin/gio
GIT = /usr/local/bin/git

ifeq (linux-gnu,$(shell print $$OSTYPE))
GIT = $(bindir)/git
else
GIT = /usr/local/bin/git
endif
GITFLAGS =

ZSH = usr/local/bin/zsh
ZNAP = ~/Git/zsh-snap/znap.zsh

BREW = $(bindir)/brew
BREWFLAGS =
HOMEBREW_PREFIX = $(exec_prefix)
HOMEBREW_CELLAR = $(HOMEBREW_PREFIX)/Cellar
HOMEBREW_REPOSITORY = $(HOMEBREW_PREFIX)/Homebrew
taps := $(taps:%=$(HOMEBREW_REPOSITORY)/Library/Taps/homebrew/homebrew-%)
formulas := $(formulas:%=$(HOMEBREW_CELLAR)/%)

PYENV_ROOT = ~/.pyenv
PYENV = $(bindir)/pyenv
PYENV_VERSION = 3.9.6
PIP = $(PYENV_ROOT)/shims/pip
PIPFLAGS =
PIPX = ~/.local/bin/pipx
PIPENV = ~/.pipenv

backups := $(wildcard $(dotfiles:%=%~))
ifneq (,$(wildcard $(OSASCRIPT)))
find = ) (
replace = ), (
backups := $(subst $(find),$(replace),$(foreach f,$(backups),(POSIX file "$(f)")))
endif

XDG_DATA_HOME = ~/.local/share
zsh-datadir = $(XDG_DATA_HOME)/zsh/
zsh-hist = $(zsh-datadir)history
zsh-hist-old = ~/.zsh_history
zsh-cdr = $(zsh-datadir).chpwd-recent-dirs
zsh-cdr-old = ~/.chpwd-recent-dirs

.NOTPARALLEL:
.ONESHELL:
.PHONY: all clean installdirs install
.SUFFIXES:

all: $(GIT)
	# all
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
ifeq (,$(wildcard /Library/Developer/CommandLineTools))
	xcode-select --install 2> /dev/null
endif
endif
ifneq (,$(wildcard $(DCONF)))
	# Write Terminal prefs to file.
	$(DCONF) dump /org/gnome/terminal/ > $(CURDIR)/terminal/dconf.txt
endif
	$(GIT) config remote.pushdefault origin
	$(GIT) config push.default current
ifneq ($(upstream),$(shell $(GIT) remote get-url upstream 2> /dev/null))
	-$(GIT) remote add upstream $(upstream) 2> /dev/null
	$(GIT) remote set-url upstream $(upstream)
endif
ifeq (,$(shell git branch -l hubsen1980-patch-1))
	-git branch -m  hubsen1980-patch-1 2> /dev/null
endif
	$(GIT) fetch $(GITFLAGS) -t upstream
	$(GIT) branch $(GITFLAGS) -u upstream/hubsen1980-patch-1 hubsen1980-patch-1
	$(GIT) pull $(GITFLAGS) --autostash upstream
	$(GIT) remote set-head upstream -a

clean:
	# clean
ifneq (,$(backups))
ifneq (,$(wildcard $(OSASCRIPT)))
	-$(OSASCRIPT) -e 'tell application "Finder" to delete every item of {$(backups)}' \
		> /dev/null
else ifneq (,$(wildcard $(GIO)))
	-$(GIO) trash $(backups)
endif
endif

installdirs:
	# install dirs
	mkdir -pm 0700 $(sort $(zsh-datadir) $(dir $(dotfiles)))

install: all clean installdirs $(taps) $(formulas) $(ZNAP) $(PYENV) $(PIP) $(PIPX) $(PIPENV)
	$(PRE_INSTALL) # install: pre
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
	-$(BREW) install $(BREWFLAGS) 2> /dev/null
endif
	-$(BREW) autoupdate $(BREWFLAGS) start --upgrade --cleanup 2> /dev/null
	$(NORMAL_INSTALL) # install: normal
	source $(ZNAP); znap install $(executables)
	$(foreach f,$(wildcard $(dotfiles)),mv $(f) $(f)~;)
ifneq (,$(wildcard $(DCONF)))
	# Load Terminal prefs from file:
	$(DCONF) load /org/gnome/terminal/ < $(CURDIR)/terminal/dconf.txt
	# Ensure that Terminal & Tilix open login shells:
	$(foreach p,\
		$(filter-out list,$(shell $(DCONF) list /org/gnome/terminal/legacy/profiles:/)),\
		$(DCONF) write /org/gnome/terminal/legacy/profiles:/$(p)login-shell true;)
	$(foreach p,$(filter-out list,\
		$(shell $(DCONF) list /com/gexperts/Tilix/profiles/)),\
		$(DCONF) write /com/gexperts/Tilix/profiles:/$(p)login-shell true;)
endif
	ln -s $(CURDIR)/zsh/.zshenv $(zshenv)
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
	ln -s $(CURDIR)/ssh/config $(sshconfig)
	ln -s $(CURDIR)/vscode/settings.json $(vscodesettings)
	ln -s $(CURDIR)/vscode/keybindings.json $(vscodekeybindings)
endif
ifeq (,$(wildcard $(zsh-hist)))
ifneq (,$(wildcard $(zsh-hist-old)))
	mv $(zsh-hist-old) $(zsh-hist)
endif
endif
ifeq (,$(wildcard $(zsh-cdr)))
ifneq (,$(wildcard $(zsh-cdr-old)))
	mv $(zsh-cdr-old) $(zsh-cdr)
endif
endif
	$(POST_INSTALL) # install: post
ifneq (,$(wildcard $(DSCL)))
ifneq (UserShell: $(SHELL),$(shell $(DSCL) . -read ~/ UserShell))
	chsh -s $(SHELL)
endif
else ifneq (,$(wildcard $(GETENT)))
ifneq ($(SHELL),$(findstring $(SHELL),$(shell $(GETENT) passwd $$LOGNAME)))
	chsh -s $(SHELL)
endif
endif

$(BREW):
	# brew
	$(BASH) -c "$$( $(CURL) -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh )"

$(taps):
	# tap
	-$(if $(wildcard $@),,\
		$(BREW) tap $(BREWFLAGS) $(subst homebrew-,homebrew/,$(notdir $@)) )

$(formulas):
	# formula
	-$(if $(wildcard $@),,$(BREW) install $(BREWFLAGS) --formula $(notdir $@))

ifeq (linux-gnu,$(shell print $$OSTYPE))
$(GIT): $(BREW)
	$(BREW) install $(BREWFLAGS) --formula git
endif

$(ZNAP):
	# znap
	@mkdir -pm 0700 $(abspath $(dir $@)..)
	$(GIT) -C $(abspath $(dir $@)..) clone $(GITFLAGS) --depth=1 \
		https://github.com/marlonrichert/zsh-snap.git

$(PYENV):
	$(BREW) install $(BREWFLAGS) --formula pyenv

$(PIP):
ifneq (,$(wildcard $BREW)))
	$(BREW) install $(BREWFLAGS) --formula zlib-ng bzip2 sqlite
endif
	PYENV_ROOT=$(PYENV_ROOT) $(PYENV) install -s $(PYENV_VERSION)
	PYENV_ROOT=$(PYENV_ROOT) $(PYENV) global $(PYENV_VERSION)

$(PIPX):
	# pipx
	$(BREW) install $(BREWFLAGS) --formula pipx

$(PIPENV):
	# pipenv
	$(PIPX) install pipenv
