# dotfiles.linux

My Linux dotfiles.

## Structure

The structure of this repository must be the same as the structure as the config files in the `$HOME` folder.

```
.
├── .config
│   ├── bat
│   ├── btop
│   ├── code-server
│   ├── karabiner
│   ├── kitty
│   ├── mc
│   ├── neofetch
│   ├── nix-darwin
│   ├── nvim
│   │   └── lua
│   │       ├── config
│   │       ├── plugins
│   │       │   ├── ai
│   │       │   ├── colorscheme
│   │       │   ├── completion
│   │       │   ├── dap
│   │       │   ├── dashboard
│   │       │   ├── extras
│   │       │   │   ├── lang
│   │       │   │   ├── pde
│   │       │   │   │   └── notes
│   │       │   │   └── ui
│   │       │   │       ├── statuscol
│   │       │   │       └── statusline
│   │       │   ├── lsp
│   │       │   └── test
│   │       └── utils
│   └── tmuxinator
├── .local
│   ├── bin
│   └── share
│       ├── code-server
│       │   └── User
│       └── mc
│           └── skins
├── .vscode
│   └── extensions
├── bin
├── etc
├── keyboards
│   ├── BNR1
│   ├── bridge75
│   ├── epomaker
│   ├── melgeek
│   │   └── mojo84
│   ├── monsgeek
│   └── nuphy
├── macos
│   └── Library
│       ├── Application Support
│       │   ├── Code
│       │   │   └── User
│       │   └── espanso
│       │       ├── config
│       │       ├── match
│       │       │   └── packages
│       │       └── user
│       └── KeyBindings
├── roles
└── utils
    └── prompts
```

## Requirements

### OS Packages

- [nix package manager](https://nixos.org/download/)
- gnustow
- fzf



## Workflow

### 1. Install Nix Package Manager in MacOS [2]

1. Use the command available on the website.
2. For MacOS, it might be necessary to add the folder `/nix/var/nix/profiles/default/bin` to `PATH` [1](https://stackoverflow.com/a/73799336). To verify if the nix package manager has been correctly installed, we can run the command `nix-shell -p neofetch --run neofetch`.
3. Install the nix-Darwin component following flakes from their websiste: https://github.com/LnL7/nix-darwin?tab=readme-ov-file#flakes .
    3a. Create a directory `mkdir -p ~/.config/nix-darwin`.
    3b. CD to this directory.
    3c. Run the command `nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"`.
    3d. Run the command `sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix`.
4. Change the platform architecture for MacOS by change the value in the variable `nixpkgs.hostplatform` to `"aarch64-darwin";`.
5. Run the command `nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/nix-darwin`.
    N.B.: This command may throw the following error: `access to absolute path '/Users' is forbidden in pure evaluation mode (use '--impure' to override)`. In this case just concatenate the previous command with the string `--impure`.
6. Add the folder `/run/current-system/sw/bin` to the `PATH`

#### 1.2. Creating a link to the flakes

Note that creating a symbolic link to the flakes makes the command `darwin-rebuild switch --flake ~/.config/nix-darwin` fails. Instead use a 'hard link' with `ln <target> <link>`

### 2. Install Nix Package Manager for Linux
 
1. Use the command available on the website.
2. It might be necessary to add the folder `/nix/var/nix/profiles/default/bin` to `PATH` [1](https://stackoverflow.com/a/73799336). To verify if the nix package manager has been correctly installed, we can run the command `nix-shell -p neofetch --run neofetch`.
3. Create a directory `mkdir -p ~/.config/nix-linux`
4. `cd` to this directory
5. Create a nix flake with the command `nix flake init`.
6. Install packages by `cd` into the flake folder an run the command `nix run --extra-experimental-features "nix-command flakes"  ~/.config/nix-linux`

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

## Using Remote NeoVim [3]

1. The remote NeoVim is configured in the Dockerfile.
2. Start the container with `docker-compose up`.
3. Connect to the remote NeoVim server with `nvim --server <host name>:6666 --remote-ui`

### References

[1] https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/
[2] https://www.youtube.com/watch?v=Z8BL8mdzWHI
[3] https://alpha2phi.medium.com/modern-neovim-lsp-and-remote-development-9b1250ee6aee
