# use zsh
SHELL:=zsh

# This can be overriden by doing `make DOTFILES=some/path <task>`
DOTFILES="$(HOME)/develop/dotfiles"
SCRIPTS="$(DOTFILES)/scripts"
INSTALL="$(DOTFILES)/installer.sh"
dir=not_override

# This is to symlink all files when All is selected in prompt
CANDIDATES = $(wildcard tmux vim zsh newsboat)
EXCLUSIONS := .DS_Store .git .gitmodules .travis.yml
DIRS   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

all: python

symlink:
	@echo "→ Setup Environment Settings"

    ifeq "$(dir)" "all"
		@echo "→ Symlinking $(DIRS) files"
		@$(foreach val, $(DIRS), sh $(DOTFILES)/$(val)/setup.sh && stow --restow -vv --ignore ".DS_Store" --ignore ".+.local" --target="$(HOME)/.$(val)" --dir="$(DOTFILES)" $(val);)
    else ifeq "$(dir)" "files"
		@echo "→ Symlinking files dir"
		stow --restow -vv --ignore ".DS_Store" --ignore ".+.local" --target="$(HOME)" --dir="$(DOTFILES)" files
    else ifeq "$(dir)" "nvim"
		sh $(DOTFILES)/files/.config/nvim/.install/run.sh
    else ifeq "$(dir)" "tmux"
		sh $(DOTFILES)/files/.config/tmux/.install/run.sh
    else
		@echo "→ Symlinking $(dir) dir"
		sh $(DOTFILES)/$(dir)/setup.sh
		stow --restow -vv --ignore ".DS_Store" --ignore ".+.local" --target="$(HOME)/.$(dir)" --dir="$(DOTFILES)" $(dir)
    endif

python:
	sh $(SCRIPTS)/python-packages.sh

composer:
	sh $(SCRIPTS)/composer-packages.sh

.PHONY: all symlink python
