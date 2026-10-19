{
  description = "Phil's standalone NixOS agent sandbox";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      sandbox = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/sandbox.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.phil = import ./home;
          }
        ];
      };
      launcher = pkgs.writeShellApplication {
        name = "sandbox";
        runtimeInputs = with pkgs; [ coreutils openssh util-linux iproute2 socat ];
        text = builtins.replaceStrings [ "@vmRunner@" ]
          [ "${sandbox.config.system.build.vm}/bin/run-agent-desktop-vm" ]
          (builtins.readFile ./host/sandbox.sh);
      };
    in {
      nixosConfigurations.sandbox = sandbox;
      packages.${system} = {
        default = launcher;
        inherit launcher;
        vm = sandbox.config.system.build.vm;
      };
      apps.${system} = {
        sandbox = { type = "app"; program = "${launcher}/bin/sandbox"; };
        default = self.apps.${system}.sandbox;
      };
      checks.${system}.source = pkgs.runCommand "sandbox-source-tests" {
        nativeBuildInputs = [ pkgs.python3 pkgs.nodejs_24 pkgs.openssh pkgs.util-linux ];
      } ''
        cd ${self}
        python3 -m unittest discover -s tests -v
        node --test dashboard/test.mjs
        touch $out
      '';
    };
}
