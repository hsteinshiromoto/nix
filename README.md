# dotfiles.linux

My Linux dotfiles.

## Structure

The structure of this repository must be the same as the structure as the config files in the `$HOME` folder.

```
.
├── bin
│   └── install.sh
├── .config
│   ├── bat
│   │   └── config
│   ├── btop
│   │   └── btop.conf
│   ├── code-server
│   │   └── config.yaml
│   └── mc
│       ├── ini
│       └── panels.ini
├── .gitconfig
├── Makefile
├── .p10k.zsh
├── .tmux.conf
└── .zshrc
```

## Requirements

### OS Packages

- [nix package manager](https://nixos.org/download/)
- gnustow
- fzf



## Workflow

### 1. Install Nix Package Manager

1. Use the command available on the website.
2. For MacOS, it might be necessary to add the folder `/nix/var/nix/profiles/default/bin` to `PATH` [1](https://stackoverflow.com/a/73799336)
3. Install the nix-Darwin component following flakes from their websiste: https://github.com/LnL7/nix-darwin?tab=readme-ov-file#flakes
    3a. Create a directory `mkdir -p ~/.config/nix-darwin`.
    3b. CD to this directory.
    3c. Run the command `nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"`.
    3d. Run the command `sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix`.
4. Change the platform architecture.
    4a. For MacOS: change the value in the variable `nixpkgs.hostplatform` to `"aarch64-darwin";`



### New dotfile

1. Create an empty file in the correct location in the repository. For instance
```bash
touch .file
```
2. Run 
```bash
stow . --adopt
```
3. Add file to the version control
```bash
git add .file
```

## Favorite Commands

### Find

Find a file in the current directory
```bash
find . -type f -name “<filename>”
```

Run grep on every file returned by find
```bash
find . -type f -name “<filename>” -exec grep -n “<string>” -i /dev/null —color=always {} ‘;’
```

### Delta

Compare two files using delta and show the output side-by-side with line numbers
```bash
delta <file1> <file2> -sn

```

### References

[1] https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/
