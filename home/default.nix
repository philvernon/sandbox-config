{ config, lib, pkgs, ... }:
let
  home = config.home.homeDirectory;
  seed = "${home}/.config/sandbox-dotfiles";
  appDependency = {
    Unit = {
      Requires = [ "sandbox-app-setup.service" ];
      After = [ "sandbox-app-setup.service" ];
    };
  };
  service = description: command: {
    Unit.Description = description;
    Service = {
      ExecStart = command;
      WorkingDirectory = home;
      Environment = [ "PATH=/etc/profiles/per-user/phil/bin:/run/current-system/sw/bin:${home}/.local/bin" ];
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
in {
  imports = [ ../tools ];
  home.username = "phil";
  home.homeDirectory = "/home/phil";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    settings.user = { name = "Phil"; email = "philvernon@users.noreply.github.com"; };
    settings.init.defaultBranch = "main";
  };
  programs.gh.enable = true;
  programs.gh.gitCredentialHelper.enable = true;

  # Writable first-boot snapshots preserve the existing plugin-manager workflow.
  # Subsequent rebuilds deliberately do not clobber experiments or lockfiles.
  home.activation.seedSandbox = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e ${lib.escapeShellArg seed} ]; then
      install -d -m 0755 ${lib.escapeShellArg seed}
      cp -R ${../dotfiles}/. ${lib.escapeShellArg seed}/
      chmod -R u+w ${lib.escapeShellArg seed}
    fi
    install -d -m 0755 ${home}/projects ${home}/.pi/agent ${home}/.local/bin ${seed}/tmux/plugins
    if [ ! -e ${home}/.pi/agent/settings.json ]; then
      install -m 0600 ${../tools/pi-settings.json} ${home}/.pi/agent/settings.json
    fi
  '';
  home.file = {
    ".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${seed}/zsh/.zshrc";
    ".zsh_plugins.txt".source = config.lib.file.mkOutOfStoreSymlink "${seed}/zsh/.zsh_plugins.txt";
    ".p10k.zsh".source = config.lib.file.mkOutOfStoreSymlink "${seed}/zsh/.p10k.zsh";
    ".local/share/antidote".source = "${pkgs.antidote}/share/antidote";
  } // builtins.listToAttrs (map (name: {
    name = ".local/bin/${name}";
    value.source = config.lib.file.mkOutOfStoreSymlink "${seed}/bin/${name}";
  }) (builtins.attrNames (builtins.readDir ../dotfiles/bin)));
  xdg.configFile = builtins.listToAttrs (map (name: {
    inherit name;
    value.source = config.lib.file.mkOutOfStoreSymlink "${seed}/${name}";
  }) [ "nvim" "tmux" "sesh" "yazi" ]);

  systemd.user.services = {
    local-dashboard = service "Local tools dashboard"
      "${pkgs.python3}/bin/python3 -m http.server 8080 --bind 0.0.0.0 --directory ${../dashboard}";
    ctools-web = lib.recursiveUpdate (service "ctools conversation history dashboard"
      "${home}/.local/bin/ctools-web --host 0.0.0.0 --port 8765 --no-logo") appDependency;
    pi-web = lib.recursiveUpdate (lib.recursiveUpdate (service "Pi Web"
      "${home}/.local/bin/pi-web -H 0.0.0.0 --port 30141 --no-open") appDependency) {
        Service.EnvironmentFile = [ "-${home}/.config/sandbox/pi-web.env" ];
      };
  };
}
