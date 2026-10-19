{ lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];
  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "agent-desktop";
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_GB.UTF-8";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  virtualisation = {
    memorySize = 6144;
    cores = 4;
    diskSize = 81920;
    graphics = false;
    # The generated runner otherwise shares the host Nix store and exchange dirs.
    useNixStoreImage = true;
    mountHostNixStore = false;
    useHostCerts = false;
    sharedDirectories = lib.mkForce {};
    forwardPorts = map (p: {
      from = "host";
      host.address = "127.0.0.1";
      host.port = p.host;
      guest.port = p.guest;
    }) [
      { host = 2222; guest = 22; }
      { host = 18080; guest = 8080; }
      { host = 8765; guest = 8765; }
      { host = 30141; guest = 30141; }
    ];
  };

  # Linger starts the user manager at boot; its installers need networking.
  systemd.services."user@" = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
  boot.kernelModules = [ "qemu_fw_cfg" ];
  users.users.phil = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    initialHashedPassword = "!";
    linger = true;
  };
  users.users.root.initialHashedPassword = "!";
  security.sudo.wheelNeedsPassword = false;
  programs.zsh.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowAgentForwarding = false;
    };
    authorizedKeysFiles = [ "/run/sandbox-authorized-keys/%u" ".ssh/authorized_keys" ];
  };
  # Only a fresh, per-sandbox public key crosses fw_cfg. No host credentials,
  # SSH agent socket, home directory, or host store are mounted in the guest.
  systemd.services.sandbox-ssh-key = {
    description = "Read sandbox public SSH key from QEMU firmware configuration";
    wantedBy = [ "multi-user.target" ];
    before = [ "sshd.service" ];
    requiredBy = [ "sshd.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      install -d -m 0755 /run/sandbox-authorized-keys
      install -m 0644 /sys/firmware/qemu_fw_cfg/by_name/opt/sandbox.ssh-key/raw \
        /run/sandbox-authorized-keys/phil
    '';
  };
  networking.firewall.allowedTCPPorts = [ 22 8080 8765 30141 ];
  services.tailscale.enable = true; # Fresh login is explicit; no auth key in image.

  environment.systemPackages = with pkgs; [
    git gh curl wget cacert jq unzip zip gnutar gzip xz file which tree
    nodejs_24 pnpm
    rustc cargo rustfmt clippy rust-analyzer
    go python3 uv pipx
    gcc gnumake cmake ninja pkg-config openssl.dev
    ripgrep fd fzf zoxide bat btop htop shellcheck shfmt
    neovim tmux sesh yazi ranger antidote
    rtk sqlite postgresql
    codex
  ];
  environment.variables = {
    EDITOR = "nvim";
  };
}
