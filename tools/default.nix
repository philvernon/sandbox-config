# Ordinary guest-side installers, orchestrated by NixOS/Home Manager.
# This builds the setup SCRIPT, not immutable Nix packages for the applications.
{ config, pkgs, ... }:
let
  revision = builtins.hashString "sha256" (
    builtins.readFile ./setup.sh
    + builtins.readFile ./npm-packages.txt
    + pkgs.nodejs_24.outPath + pkgs.python3.outPath + pkgs.uv.outPath + pkgs.yazi.outPath
  );
  setup = pkgs.writeShellApplication {
    name = "sandbox-app-setup";
    runtimeInputs = with pkgs; [ nodejs_24 python3 uv yazi git gcc gnumake pkg-config coreutils cacert ];
    text = builtins.replaceStrings
      [ "@revision@" "@npmPackages@" ]
      [ revision "${./npm-packages.txt}" ]
      (builtins.readFile ./setup.sh);
  };
in {
  systemd.user.services.sandbox-app-setup = {
    Unit = {
      Description = "Install declared sandbox applications";
      # The user manager starts via linger, after the system boot dependencies.
      # Network failures are reported, never bypassed with fallback installers.
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${setup}/bin/sandbox-app-setup";
      WorkingDirectory = config.home.homeDirectory;
      Environment = [
        "HOME=${config.home.homeDirectory}"
        "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
        "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
      ];
      TimeoutStartSec = "30min";
      UMask = "0077";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
