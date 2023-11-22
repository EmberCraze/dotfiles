#!/bin/bash

declare -r GITHUB_REPOSITORY="EmberCraze/dotfiles"
declare -r GITHUB_REPO_URL_BASE="https://github.com/$GITHUB_REPOSITORY"
declare -r DOTFILES_UTILS_URL="https://raw.githubusercontent.com/$GITHUB_REPOSITORY/master/scripts/utils.sh"

declare -r DOTFILES="$HOME/develop/MegaGithubSync/dotfiles"

download() {
    local url="$1"
    local output="$2"

    if command -v "curl" &> /dev/null; then
        curl -LsSo "$output" "$url" &> /dev/null
        return $?

    elif command -v "wget" &> /dev/null; then
        wget -qO "$output" "$url" &> /dev/null
        return $?
    fi
    return 1
}

download_utils() {
    local tmpFile=""
    tmpFile="$(mktemp /tmp/XXXXX)"

    download "$DOTFILES_UTILS_URL" "$tmpFile" \
        && . "$tmpFile" \
        && rm -rf "$tmpFile" \
        && return 0
   return 1
}

print_prompt() {
  print_question "What you want to do?\n"

  PS3="Enter your choice (must be a number): "

  MENU_OPTIONS=("All" "Install package manager" "Install Git" "Symlink files" "Change shell" "Quit")

  select opt in "${MENU_OPTIONS[@]}"; do
    case $opt in
    "All")
      all
      break
      ;;
    "Install package manager")
      install_package_manager
      break
      ;;
    "Install Git")
      install_git
      break
      ;;
    "Symlink files")
      install_package_manager
      symlink_files
      break
      ;;
    "Override macOS System Settings")
      override_macOS_system_settings
      break
      ;;
    "Change shell")
      ask_for_sudo_permission
      install_package_manager
      install_zsh
      break
      ;;
    "Quit")
      break
      ;;
    *)
       print_error "Invalid option!"
       PS3=$( echo -e $BLUE"Enter a valid choice? ") # this displays the common prompt
       ;;
     esac
  done
}

on_start() {

  print_header

  print_repo_info $DOTFILES

  print_info "This script will guide you through installing essentials for your Linux OS."
  print_info "It won't install anything without your agreement!"

  ask_for_confirmation "Do you want to proceed with installation?"

  if ! answer_is_yes; then
    exit 1
  fi

}

install_package_manager() {
  # install nix package manager
  print_info "Checking if Nix is installed..."
  if [ ! -d "/nix" ]; then
    # Nix is not installed

    # Get user concent
    print_info "Seems like you don't have Nix installed!"
    ask_for_confirmation "Do you agree to proceed with Nix installation?"


    if ! answer_is_yes; then
      exit 1
    fi

    print_info "Installing Nix..."
    print_info "This may take a while"

    # Install Nix
    curl -L https://nixos.org/nix/install | sh -s -- --daemon

    # Reload terminal
    source ~/.bashrc

    # Update source list
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable
    nix-channel --update

    # Install stow for dotfile management
    nix-env -f "<nixpkgs>" -iA stow

	# Add nix to path

  else
    print_info "You already have Nix installed, nothing to do here skipping... 💨"
  fi

  finish
}

install_git() {
  print_info "Trying to detect installed Git..."

  if ! cmd_exists "git"; then
    print_info "Seems like you don't have Git installed!"

    ask_for_confirmation "Do you agree to proceed with Git installation?"

    if ! answer_is_yes; then
      return
    fi

    print_info "Before installing git, we need to install Nix package manager"

    ask_for_confirmation "Do you agree to proceed with Nix installation?"

    if ! answer_is_yes; then
      return
    fi

    install_package_manager

    print_in_purple "\n • Installing Git\n\n"

    nix-env -f "<nixpkgs>" -iA git

  else
    print_info "You already have Git installed! nothing to do here skipping... 💨"
  fi

#  ask_for_confirmation "Do you want to setup SSH?"
#
#  if ! answer_is_yes; then
#   return
#  fi
#
#  print_in_purple "\n • Set up GitHub SSH keys\n\n"
#
#  if ! is_git_repository; then
#    print_error "Not a Git repository"
#    exit 1
#  fi
#
#  ssh -T git@github.com &> /dev/null
#
#  if [ $? -ne 1 ]; then
#   set_github_ssh_key
#  fi
#
#  print_result $? "Set up GitHub SSH keys"
#
  finish
}

install_zsh() {

	print_info "Trying to detect installed ZSH..."

	if ! cmd_exists "zsh"; then
		print_info "Seems like you don't have ZSH installed!"
		ask_for_confirmation "Do you agree to proceed with ZSH installation?"

		if ! answer_is_yes; then
			return
		fi

		print_in_purple "\n • Installing ZSH\n\n"

		nix-env -f "<nixpkgs>" -iA zsh
	else
		print_info "ZSH already installed, nothing to do here skipping ... 💨"
	fi

	# Switching ZSH shell

    print_in_purple "\n • Switching to ZSH Shell\n\n"
    chsh -s "/bin/zsh"
	print_warning "You'll need to log out for this to take effect!"

	# local NIX_ZSH_PATH="/usr/local/bin/zsh"
#		if ! grep -q "$BREW_ZSH_PATH" /etc/shells; then
#
#			print_in_purple "\n • Switching to ZSH Shell\n\n"
#			local ZSH_PATH=$(which zsh)
#
#			if [ -x "$BREW_ZSH_PATH" ]; then
#				ZSH_PATH="$BREW_ZSH_PATH"
#			else
#				print_warning "Your system is using (outdated) ZSH shell"
#			fi
#
#			echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
#			chsh -s "$ZSH_PATH" "$(whoami)"
#		else
#			print_info "No need to switch shell, you are using Homebrew zsh already"
#		fi
#

	finish
}

symlink_files() {
  print_info "Trying to detect if you have already cloned the dotfiles..."

  if [[ -d $DOTFILES ]]; then
    print_info "Seems like you have the dotfiles installed!"

    print_in_purple "\n • Create local config files\n\n"

    create_gitconfig_local
    create_zshrc_local
    create_vimrc_local

    print_in_purple "\n • Symlinking files/folders\n\n"
    cd "$DOTFILES" &&
      make --ignore-errors symlink dir=all &&
      make --ignore-errors symlink dir=files
      #make gpg

  else
    print_info "You don't the dotfiles $DOTFILES in your machine!"
  fi
}

#bootstrap_apps() {
#  if [[ -d $DOTFILES ]]; then
#    ask_for_confirmation "Would you like to bootstrap your environment by installing apps?"
#
#    if ! answer_is_yes; then
#      break
#    fi
#
#    if [ "$(uname)" = "Darwin" ]; then
#
#      if [ "$(echo "$0" | tr '[:upper:]' '[:lower:]')" == "work"  ]; then
#        cd "$DOTFILES" && make --ignore-errors homebrew-work
#      else
#        cd "$DOTFILES" && make --ignore-errors homebrew-personal
#      fi
#
#    else
#      print_info "Install Linux packages here..."
#    fi
#
#  else
#    print_info "Skipping ... 💨!"
#  fi
#
#  finish
#}

all() {
  ask_for_sudo_permission
  install_package_manager
  install_git
  install_cli_tools
#  clone_dotfiles
  install_zsh
  symlink_files
#  bootstrap_macOS_apps

  FAILED_COMMAND=$(fc -ln -1)

  if [ $? -eq 0 ]; then
    print_success "Done."
  else
    print_error "Something went wrong, [ Failed on: $FAILED_COMMAND ]"
  fi
}

main() {

  # Ensure that the following actions
  # are made relative to this file's path.

  cd "$(dirname "${BASH_SOURCE[0]}")" \
      || exit 1

  # Load utils

    if [ -x "scripts/utils.sh" ]; then
        . "scripts/utils.sh" || exit 1
    else
        download_utils || exit 1
    fi

  on_start
  print_prompt
  on_finish
}

main
