#!/usr/bin/env bash

# Safer bash scripts with 'set -euxo pipefail'
set -Eueo pipefail
trap on_error SIGKILL SIGTERM

DOTFILES="$HOME/dotfiles"
GITHUB_REPO_URL_BASE="https://github.com/AhmedAbdulrahman/dotfiles"
HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/master/install"
LINUXBREW_INSTALLER_URL="https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh"

e='\033'
RESET="${e}[0m"
BOLD="${e}[1m"
CYAN="${e}[0;96m"
RED="${e}[0;91m"
YELLOW="${e}[0;93m"
GREEN="${e}[0;92m"

_exists() {
  command -v $1 > /dev/null 2>&1
}

# Success reporter
info() {
  echo -e "${CYAN}${*}${RESET}"
}

# Error reporter
error() {
  echo -e "${RED}${*}${RESET}"
}

# Success reporter
success() {
  echo -e "${GREEN}${*}${RESET}"
}

# End section
finish() {
  success "Done!"
  echo
  sleep 1
}

export DOTFILES=${1:-"$HOME/dotfiles"}
GITHUB_REPO_URL_BASE="https://github.com/AhmedAbdulrahman/dotfiles"
HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/master/install"
LINUXBREW_INSTALLER_URL="https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh"
brew="/usr/local/bin/brew"

# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || exit 1

on_start() {

  info  "   _____   ____ _______ ______ _____ _      ______  _____  "
  error "  |  __ \ / __ \__   __|  ____|_   _| |    |  ____|/ ____| "
  info  "  | |  | | |  | | | |  | |__    | | | |    | |__  | (___   "
  error "  | |  | | |  | | | |  |  __|   | | | |    |  __|  \___ \  "
  info  "  | |__| | |__| | | |  | |     _| |_| |____| |____ ____) | "
  error "  |_____/ \____/  |_|  |_|    |_____|______|______|_____/  "
  error "                                                           "
  info  "                  by @AhmedAbdulrahman                     "


  if [ -d "$DOTFILES/.git" ]; then
command cat <<EOF
      *******************************************
              $(git --git-dir "$DOTFILES/.git" --work-tree "$DOTFILES" log -n 1 --pretty=format:'%C(yellow)Last commit SHA:  %h')
              $(git --git-dir "$DOTFILES/.git" --work-tree "$DOTFILES" log -n 1 --pretty=format:'%C(red)Commit date:    %ad' --date=short)
              $(git --git-dir "$DOTFILES/.git" --work-tree "$DOTFILES" log -n 1 --pretty=format:'%C(cyan)Author:  %an')
      ********************************************
EOF
  fi

  info "This script will guide you through installing essentials for your (Mac/Linux/Windows WIP)OS."
  info "It won't install anything without your agreement!"
  echo
  read -p "Do you want to proceed with installation? [y/N] " -n 1 answer
  echo
  if [ ${answer} != "y" ]; then
    exit 1
  fi

}

install_cli_tools() {
  # Install Cli Tools. 
  # Note:There's not need to install XCode tools on Linux
  if [ `uname` == 'Linux' ]; then
    return
  fi

  info "Trying to detect installed Command Line Tools..."

  if ! [ $(xcode-select -p) ]; then
    echo "You don't have Command Line Tools installed!"
    read -p "Do you agree to install Command Line Tools? [y/N] " -n 1 answer
    echo
    if [ ${answer} != "y" ]; then
      exit 1
    fi

    info "Installing Command Line Tools..."
    echo "Please, wait until Command Line Tools will be installed, before continue."

    xcode-select --install
  else
    success "You already have Command Line Tools installed, nothing to do here skipping ... 💨"
  fi

  finish
}

install_package_manager() {
  
  # macOS 
  if [ `uname` == 'Darwin' ]; then

    info "Checking if Homebrew is installed..."
    
    if ! _exists $brew; then
      echo "Seems like you don't have Homebrew installed!"
      read -p "Do you agree to proceed with Homebrew installation? [y/N] " -n 1 answer
      echo

      if [ ${answer} != "y" ]; then
        exit 1
      fi

      info "Installing Homebrew..."
      echo "This may take a while"
      
      ruby -e "$(curl -fsSL ${HOMEBREW_INSTALLER_URL})"
      # Make sure we’re using the latest Homebrew.
      $brew update
      # Upgrade any already-installed formulae.
      $brew upgrade --all
    else
      success "You already have Homebrew installed, nothing to do here skipping ... 💨"
      $brew -v
    fi

  # Linux 
  elif [ `uname` == 'Linux' ]; then 

    info "Checking if Linuxbrew is installed..."

    if [! -d "$HOME/.linuxbrew" ]; then
      echo "Seems like you don't have Linuxbrew installed!"
      read -p "Do you agree to proceed with Linuxbrew installation? [y/N] " -n 1 answer
      echo

      if [ ${answer} != "y" ]; then
        exit 1
      fi

      info "Installing Linuxbrew..."
      echo "This may take a while"

      ruby -e "$(curl -fsSL ${LINUXBREW_INSTALLER_URL})"
      # Make sure we’re using the latest Homebrew.
      brew update
      # Upgrade any already-installed formulae.
      brew upgrade --all
      
      brew doctor || true

      mkdir $HOME/.linuxbrew/lib
      ln -s lib $HOME/.linuxbrew/lib64
      ln -s $HOME/.linuxbrew/lib $HOME/.linuxbrew/lib64
      ln -s /usr/lib64/libstdc++.so.6 /lib64/libgcc_s.so.1 $HOME/.linuxbrew/lib/

    else
      success "You already have Linuxbrew installed, nothing to do here skipping... 💨"
    fi
  
  fi

  finish
}

install_git() {

  # Install Git 
  info "Trying to detect installed Git..."

  if ! _exists git; then
    echo "Seems like you don't have Git installed!"
    read -p "Do you agree to proceed with Git installation? [y/N] " -n 1 answer
    echo
    if [ ${answer} != "y" ]; then
      exit 1
    fi

    info "Installing Git..."

    if [ `uname` == 'Darwin' ]; then
      brew install git
    elif [ `uname` == 'Linux' ]; then
      sudo apt-get install build-essential curl file git
    else
      error "Error: Failed to install Git!"
      exit 1
    fi
  else
    success "You already have Git installed, nothing to do here skipping ... 💨"
  fi

  finish
}

install_zsh() {
  
  #Install ZSH
  info "Trying to detect installed Zsh..."

  if ! _exists zsh; then
    echo "Seems like you don't have Zsh installed!"
    read -p "Do you agree to proceed with Zsh installation? [y/N] " -n 1 answer
    echo
    if [ ${answer} != "y" ]; then
      exit 1
    fi

    info "Installing Zsh..."

    if [ `uname` == 'Darwin' ] || [ `uname` == 'Linux' ]; then
      brew install zsh
    else
      error "Error: Failed to install Zsh!"
      exit 1
    fi
  else
    success "You already have Zsh installed, nothing to do here skipping ... 💨"
  fi

  if _exists zsh; then
    info "Setting up Zsh as default shell..."

    echo "The script will ask you the password for sudo when changing your default shell via chsh -s"
    echo

    chsh -s "$(command -v zsh)" || error "Error: Cannot set Zsh as default shell!"
    echo "You'll need to log out for this to take effect"
  fi

  finish
}

install_dotfiles() {
  info "Trying to detect if Ahmed's dotfiles is installed in $DOTFILES..."

  if [ ! -d $DOTFILES ]; then
    echo "Seems like you don't have Ahmed's dotfiles installed!"
    read -p "Do you agree to proceed with Ahmed's dotfiles installation? [y/N] " -n 1 answer
    echo
    if [ ${answer} != "y" ]; then
      exit 1
    fi

    echo "Cloning Ahmed's dotfiles"
    git clone --recursive "$GITHUB_REPO_URL_BASE.git" $DOTFILES

  else
    success "You already have Ahmed's dotfiles installed. Skipping..."
  fi

  read -p "Enter files you would like to install separated by 'space' : " input

  for module in ${input[@]}; do
    info "Installing $module config ..."

    [[ ! -f "$module/setup.sh" ]] && error "$module config not found!" && return
    "$module/setup.sh"            && info  "$module config installed successfully!"
  done

  finish
}

bootstrap() {
  echo "Seems like you don't have Ahmed's dotfiles installed!"
  read -p "Would you like to bootstrap your environment by installing Homebrew formulae? [y/N] " -n 1 answer
  echo
  if [ ${answer} != "y" ]; then
    return
  fi

  $DOTFILES/scripts/bootstrap.zsh

  finish
}

on_finish() {
  echo
  success "Setup was successfully done!"
  success "Happy Coding!"
  echo
  echo -ne $RED'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
  echo -e  $RESET$BOLD',------,'$RESET
  echo -ne $YELLOW'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
  echo -e  $RESET$BOLD'|   /\_/\\'$RESET
  echo -ne $GREEN'-_-_-_-_-_-_-_-_-_-_-_-_-_-'
  echo -e  $RESET$BOLD'~|__( ^ .^)'$RESET
  echo -ne $CYAN'-_-_-_-_-_-_-_-_-_-_-_-_-_-_'
  echo -e  $RESET$BOLD'""  ""'$RESET
  echo
  info "P.S: Don't forget to restart a terminal :)"
  echo "Cheers"
  echo
}

on_error() {
  echo
  error "Wow... Something serious happened!"
  error "In case if you need any help, raise an issue -> ${CYAN}${GITHUB_REPO_URL_BASE}issues/new${RESET}"
  echo
  exit 1
}

main() {
  on_start "$*"
  install_cli_tools "$*"
  install_package_manager "$*"
  install_git "$*"
  install_zsh "$*"
  install_dotfiles "$*"
  bootstrap "$*"
  on_finish "$*"
}

main "$*"