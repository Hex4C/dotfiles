<img src="assets/banner.png" alt="Kurzgesagt banner for style points">
Image: Kurzgesagt

# Hex4C Dot files


This is my private repository for managing and storing my dotfiles for unix systems. 
Mainly Linux and macOS

## Requirements

I utilise GNU stow for storing all of my .config files. I have a specific setup for
macOS and linux where there's two versions of .zshrc due to the OS:es utilising different
packages.

- GNU stow 
- git


## Usage

1. Clone the repository `git clone git@github.com:Hex4C/dotfiles.git ~/.dotfiles`
2. `cd ~/.dotfiles`
3. `stow <package>`

### Example

```console
stow zsh-linux
stow git
stow lazygit
stow nvim
stow tmux
```

#### Stowing specific files with stow

To stow specific files if you want to utilise direct names or directorys instead it's a bit different
but can be done with the command:

`stow -d <directory> -t <target>` 

For example the command `stow -d ~/.dotfiles -t ~ vim` would tell stow to look for the package `~/.dotfiles/vim` 
and stow it in the `~` diretory.

## Viewing the stowed files
The files can be viewed by their difference in colours in most terminals or with the `ls -la` command
which will display the symlinks as `file123 -> original file..`.

## stow ignore file

The link below is the default stow ignore file and at the moment no specific stow ignore file has been created.

It's important that only config files are stored in here, files that can be rebuilt don't belong in here and 
should instead be generated when needed. Files not needed should be added to the .gitignore file.

[Stow default ignore file](https://www.gnu.org/software/stow/manual/html_node/Types-And-Syntax-Of-Ignore-Lists.html)

