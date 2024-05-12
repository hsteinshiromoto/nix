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

- git
- gnustow
- fzf

## Workflow

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

### References

[1] https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/
