{
  description = "NixOS configurations for nixos development";

  inputs = {
    nixpkgs.url = "github:xtruder/nixpkgs/xtruder-nixos-unstable";
    nix-profiles.url = "github:xtruder/nix-profiles/master";
  };

  outputs = { self, nix-profiles, nixpkgs }: let
    pkgs = import "${nixpkgs.outPath}";

    pkgsModule = {config, ...}: {
      nixpkgs.pkgs = pkgs {
        inherit (config.nixpkgs) config overlays localSystem crossSystem;
      };
    };

    configuration = {
      imports = with nix-profiles.lib.nixos; [
        roles.dev-vm
      ];

      networking = {
        hostName = "nixos-dev";
        domain = "x-truder.net";
      };

      users.users.vagrant = {
        extraGroups = [ "docker" ];
      };

      home-manager.users.vagrant = {config, ...}: {
        imports = with nix-profiles.lib.home-manager; [
          roles.server.dev
          themes.materia
          themes.colorscheme.google-dark

          dev.go
          dev.nix
          dev.python
        ];
      };
    };
  in {
    nixosConfigurations.dev-vagrant-libvirt = nix-profiles.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ pkgsModule configuration ({lib, ...}: with lib; {
        imports = with nix-profiles.lib.nixos; [
          hw.qemu-vm
          environments.vagrant
          roles.base
        ];
      })];
    };

    devShell.x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
      buildInputs = [
        vagrant
      ];

      shellHook = ''
        if ! vagrant plugin list | grep vagrant-sshfs; then
          vagrant plugin install vagrant-sshfs
        fi

        export PATH=${openssh}/libexec:$PATH
      '';
    };
  };
}
