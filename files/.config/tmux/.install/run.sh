#!/usr/bin/bash

# COLORS
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NC=$(tput sgr0)
BOLD=$(tput bold)

declare -r XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-"$HOME/.config"}"
declare -r CONFIG_DIR="${CONFIG_DIR:-"$XDG_CONFIG_HOME/tmux"}"
declare -r DOTFILES_DIR="$HOME/develop/MegaGithubSync/dotfiles/files/.config"

# MAIN
function main() {
	check_tput_install

	 echo -e "${BOLD}${YELLOW}Installation will override your $CONFIG_DIR directory!${NC}\n"

	while [ true ]; do
		msg
		read -p $'Do you wish to install tmux config now? \e[33m[y/n]\e[0m: ' yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit;;
			* ) echo "${BOLD}Please answer ${YELLOW}y${NC}${BOLD} or ${YELLOW}n${NC}${BOLD}.${NC}";;
		esac
	done

	remove_current_config
	create_tmux_config_dir
	setup
	# finish
}

function msg() {
  local text="$1"
  local flag="$2"
  local line="$3"
  local div_width="80"

  # Render line
  if [ "$line" != "0" ]; then
    printf "%${div_width}s\n" ' ' | tr ' ' -
  fi

  # Render text
  if [ "$flag" == "1" ]; then
    echo -e "$text"
  else
    echo -n "$text"
  fi
}

function check_tput_install() {
  if ! command -v tput &>/dev/null; then
    print_missing_dep_msg "tput"
    exit 1
  fi
}

function check_tput_install() {
  if ! command -v tput &>/dev/null; then
    print_missing_dep_msg "tput"
    exit 1
  fi
}

function remove_current_config() {
  cd "$HOME"
  msg "${BOLD}Removing current tmux configuration... ${NC}"
  rm -rf "$CONFIG_DIR"
  echo -e "${GREEN}${BOLD}Done${NC}"
}

function create_tmux_config_dir() {
  cd "$HOME"
  msg "${BOLD}Creating tmux folder in root directory... ${NC}"
  mkdir -p "$CONFIG_DIR"
  echo -e "${GREEN}${BOLD}✓ Done${NC}"

  msg "${BOLD}Symlinking all tmux config... ${NC}"
  stow --restow -vv --ignore ".DS_Store" --ignore ".+.local" --ignore='^README.*' --target="$CONFIG_DIR" --dir="$DOTFILES_DIR" tmux
  echo -e "${GREEN}${BOLD}✓ Done${NC}"
}

function setup() {
  msg "${BOLD}Installing tmux plugin manager...${NC}" 1
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

  msg "${BOLD}${GREEN}Done${NC}" 1 0
  msg "${BOLD}${GREEN}Plugin installation completed!${NC}" 1
}

main
