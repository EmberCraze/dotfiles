# Ahmed’s dotfiles adapted for ZSH

> Running [**iTerm2**](https://www.iterm2.com/) with [**oh-my-zsh**](https://github.com/robbyrussell/oh-my-zsh) and [**Spaceship-zsh-theme**](https://github.com/denysdovhan/spaceship-zsh-theme).

The color scheme is [**iTerm2 - Snazzy**](https://github.com/sindresorhus/iterm2-snazzy) for _iTerm2_ and the font is [**Danke Mono**](https://dank.sh/)

![Screenshot](intro.gif)

There are tons of useful things in here:

- ⚡️ Power up and beautify terminal with [“Oh My ZSH!”](http://ohmyz.sh/) is already built–in.
- [🚀 Spaceships ZSH](https://github.com/denysdovhan/spaceship-prompt) as a prompt.
- [🌺 zplug](https://zplug.sh) for dependency management.
- 💄 Syntax highlighting of commands.
- ⌨️ Autosuggestions for most of commands.
- 🕵️‍ Fuzzy Search for VIM, Git and history
- 🏎 Useful [aliases](./zsh/zsh_aliases).
- Git config, global `.gitignore` file and aliases.

Missing feature? 🍴 Fork this repo and make it better!

## Installation

#### ⚠️ Disclaimer ⚠️

These are **my** dotfiles, so please feel free to take anything you want but do so **at your own risk**. 🙂 You should first fork this repository, review the code, and remove the things you don’t want or need. Don’t blindly use stuff unless you know what that entails.

Also — and this is just my personal opinion — I can **highly** recommend setting up your own `.files` (instead of forking an existing project) and moving along step by step. There is much to be learned and no better feeling than having full control over the things that are happening and being aware where everything is and what exactly it does. But that’s just me. 🙂

#### Clone via Curl OR Wget

Dotfiles are installed by running one of the following commands in your terminal:

via `curl`

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AhmedAbdulrahman/zsh-dotfiles/master/installer.sh)"
```

via `wget`

```bash
bash -c "$(wget https://raw.githubusercontent.com/AhmedAbdulrahman/zsh-dotfiles/master/installer.sh -O -)"
```

#### Clone with Git

On a fresh install of macOS, run:

```
sudo softwareupdate -i -a
xcode-select --install
```

Then clone the repo and run `installer.sh`:

```
git clone git@github.com:AhmedAbdulrahman/zsh-dotfiles.git ~/.dotfiles
source ~/.dotfiles/installer.sh
```

#### Install Configuration

You will be prompt with few questions, answer based on your need then type what config file you want to install see below:

```bash
Enter files you would like to install separated by 'space' : zsh tmux vim
```

## Essentials 👩‍💻☕️

### Oh-My-Zsh Plugins

These plugins are included when you install `Oh-My-Zsh` Framework:

- [`git`](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/git) — git aliases and functions.
- [`npm`](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/npm) — Provides completion as well as adding many useful aliases.
- [`yarn`](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/yarn) — the same as for `npm`, but for `yarn`
- [`nvm`](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/nvm) — auto-sourcing `nvm`.
- [`sudo`](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/sudo) — `[Esc] [Esc]` to re-run previous command with sudo.
- [`colored-man-pages`](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/colored-man-pages) — colorize the man page

### External Plugins - Zsh Improvements

- [`forgit`](https://github.com/wfxr/forgit) — utility tool for git taking advantage of fuzzy finder fzf.
- [`git-extras`](https://github.com/tj/git-extras) — Small git utilities
- [`diff-so-fancy`](https://github.com/so-fancy/diff-so-fancy) — Makes your diff's human readable instead of machine readable
- [`zsh-better-npm-completion`](https://github.com/lukechilds/zsh-better-npm-completion) — Better completion utility for npm
- [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting) — Provides syntax highlighting for the shell zsh. It enables highlighting of commands whilst they are typed at a zsh prompt into an interactive terminal
- [`zsh-completions`](https://github.com/zsh-users/zsh-completions) — Additional completion definitions for Zsh.
- [`zsh-autopair`](https://github.com/hlissner/zsh-autopair) — simple plugin that auto-closes, deletes and skips over matching delimiters in zsh intelligently
- [`zsh-history-substring-search`](https://github.com/zsh-users/zsh-history-substring-search) — Provides a history search where you can type in any part of any command from history and then press chosen keys, such as the UP and DOWN arrows, to cycle through matches.
- [`zsh-autosuggestions`](https://github.com/zsh-users/zsh-autosuggestions) — fast autosuggestions for zsh, It suggests commands as you type, based on command history.
- [`wifi-password`](https://github.com/rauchg/wifi-password) — Small utility to get the password of the wifi you're on _macOS only_.
- [`z`](https://github.com/rupa/z) — Smart jump around plugin that tracks your most used directories, based on 'frecency'. After a short learning phase, z will take you to the most 'frecent' directory that matches ALL of the regexes given on the command line, in order.
- [`k`](https://github.com/supercrabtree/k) — Makes directory listings more readable, adding a bit of color and some git status information on files and directories.
- [`alias-tips`](https://github.com/djui/alias-tips) — Cool utility that helps remembering those aliases you defined once ;)
- [`almostontop`](https://github.com/Valiev/almostontop) — Utility that clears previous command output every time before new command executed in shell

### Theme

- [Spaceship](https://github.com/denysdovhan/spaceship-prompt) — Minimalistic, powerful and extremely customizable Zsh prompt. It combines everything you may need for convenient work, without unnecessary complications, like a real spaceship.

## License

MIT © [Ahmed Abdulrahman](https://github.com/AhmedAbdulrahman)
