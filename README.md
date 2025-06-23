# Nix Flakes

## Repository Structure

```
.
├── bin
│   ├── docker-nix.conf
│   └── make_iso.sh
├── CLAUDE.md
├── custom_iso.nix              <- NixOS image configuration
├── mbp2025                     <- MacOS flake with Nix-Darwin
│   ├── flake.lock
│   └── flake.nix
├── flake.lock
├── flake.nix
├── LICENSE
├── Makefile
├── mbp2023
│   └── flake.nix
├── nix.conf
├── README.md
└── servo
    ├── configuration.nix
    ├── flake.lock
    ├── flake.nix
    └── hardware-configuration.nix

```

## Build Nix ISO based on the flake settings

In the root folder of this git repository, run the following command:

```bash
 nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./custom_iso.nix
```

## Servidor

1. Create the symbolic links of the files in `servo/` folder to `/etc/nixos`.

2. Run the command from the folder `/etc/nixos/`
```bash
sudo nix flake update --flake . --impure
```

3. Rebuild with from the project root folder
```bash
sudo nixos-rebuild test --flake .#servidor --impure
```

To switch to a new build, replace the `test` with `switch`.

## Darwin

1. Create a folder `~/.config/nix`.

1. Install [nix-darwin](https://github.com/nix-darwin/nix-darwin) running the command `sudo nix run nix-darwin -- switch --flake .#MBP2023` in the project root of this repository.

Two flakes divided into two folders:

```
.
├── mbp2025             <- MBP2025 flake file
│   ├── flake.lock
│   └── flake.nix
├── mbp2023             <- MBP2023 flake file
│   └── flake.nix
```

Update each computer with the corresponding command:

```bash
darwin-rebuild switch --flake ~/.config/nix/mbp2025#MBP2025
```
or
```bash
darwin-rebuild switch --flake $(pwd)/mbp2023#MBP2023
```


## Building the ISO

To build the NixOS ISO from this configuration, you will need to have Nix installed and flakes enabled. Due to the target architecture (`x86_64-linux`) being different from the host architecture (`aarch64-darwin`), you need to configure a remote builder or use emulation.

1.  **Configure Nix for remote building:**

    You can use the provided `nix.conf` file to configure your Nix environment. You can either copy its contents to your `~/.config/nix/nix.conf` or use it directly with the `nix` command.

2.  **Build the ISO:**

    Run the following command from the root of the repository:

    ```bash
    nix build .#nixosConfigurations.custom-iso.config.system.build.isoImage --extra-experimental-features "nix-command flakes" --option extra-experimental-features "nix-command flakes" --config-file ./nix.conf
    ```

    This command tells Nix to use the local `nix.conf` file, which enables the use of a Linux builder.

The resulting ISO image will be in the `result/` directory.
