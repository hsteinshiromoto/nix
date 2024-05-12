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

## Workflow

### New dotfile

- Create an empty file in the correct location in the repository. For instance
  ```bash
  touch .file
  ```
- Run 
  ```bash
  stow . --adopt
  ```
- Add file to the version control
  ```bash
  add .file
  ```

### References

[1] https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/
