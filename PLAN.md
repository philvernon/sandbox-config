# Sandbox configuration: agreed scope and recovery plan

## Goal

One standalone, PUBLIC `philvernon/sandbox-config` repository, developed in
`/home/phil/projects/sandbox-config`. From Phil's Arch Linux host, one Nix command
must build and start a configured NixOS coding-agent sandbox using the supported
NixOS QEMU VM runner. No manual ISO installation, Cockpit requirement, libvirt
integration, or migration of the existing Debian VM.

Pi means the Pi CODING AGENT (`@earendil-works/pi-coding-agent`). This project has
nothing to do with Raspberry Pi hardware.

## Owner requirements

- Keep the configuration straightforward and top-level. Prefer existing Nixpkgs
  packages; do not turn application setup into a custom dependency-packaging
  project.
- Configure the OS, development tools, terminal/editor configuration, applications
  and services from this repo. Application installation must be initiated by the
  configuration, not left as a collection of undocumented manual tasks.
- Do NOT carry over the source VM's npm manifests/lockfiles as a way of packaging
  Pi's extension dependency tree. Pi manages its own extensions.
- A declaratively configured guest setup step using ordinary npm/uv installers
  has been discussed. Do not describe that as a manual install or as an immutable
  Nix package. Clearly distinguish it from native Nixpkgs packaging.
- Remove the custom npm derivations, Python/tokenizer packaging workaround,
  legacy-peer flags, and binary compatibility shims added in this draft.
- If an actual incompatibility requires working around Nix or changing the agreed
  approach, STOP and explain it. No silent compatibility layers, patches,
  fallback installers, disabled safety checks or dependency-resolution flags.
- Capture the working VM-specific dotfiles independently of Phil's main
  dotconfig. Include the local Neovim changes, not just committed upstream files.
  No obligation to sync this snapshot with the Mac configuration.
- Include dashboard sources in `dashboard/`; group Pi/Pi Web/pi-muxr/local
  extension/ctools declarations or setup sources in `tools/`.
- Public repo: NO credentials, auth/session state, databases, private project
  data, model-provider credentials or inherited spending permissions.
- Do not change the original dotconfig, platform checkout, or existing web
  services. Do not install/activate the new configuration over this Debian VM.
- Do not delete or replace the existing VM, change the Arch host remotely, or
  invoke paid model calls to verify setup.

## Desired contents

- Base development tools: Node/npm, Rust/Cargo and associated development tools,
  Go, Python/uv, compilers/build utilities, Git and GitHub CLI.
- Current zsh/Powerlevel10k/Antidote, tmux, Neovim, sesh, yazi configuration and
  helper scripts. Keep normal plugin-manager behaviour, not a rewrite of the
  configs into Nix. Writable runtime state stays out of the Nix store.
- Pi coding agent, Pi Web, pi-muxr, Codex and ctools. Pi manages its extensions;
  retain custom local extension source without copying runtime logs/config/auth.
- Agent Deck, Agent of Empires and RTK were discovered in the original VM. Owner
  initially requested presence-only README notes for these. Do not make their
  custom packaging a reason to complicate/block the core sandbox.
- Dark, square, minimal wireframe dashboard with links to Pi Web and ctools.
  Paperclip was noted as installed/stopped on the original VM and deferred;
  do not add it to the fresh sandbox automatically.
- Git identity/settings and GitHub CLI credential-helper setup. Fresh GitHub,
  Pi, Codex and Tailscale authentication stays explicit and outside Git/images.

## VM and host behaviour

- x86_64 Linux host; Phil's host is Arch with KVM already working.
- Use NixOS's generated QEMU runner, with a small systemd-user launcher for
  background operation, status/logs, SSH and shutdown. No new VM framework.
- Repo entry point: `nix run .#sandbox` (also runnable by GitHub flake URL).
- Separate persistent guest disk under host user state, not inside the repo.
  Start/stop must not silently erase it or adopt/kill unrelated processes.
- No host home, checkout, Nix store, SSH agent or credentials mounted into the
  guest. The supported runner defaults to sharing the host store: explicitly
  disable those shares and use its supported private store-image option.
- Fresh per-sandbox public SSH key can be supplied at launch; private half stays
  on the host. No published reusable passwords or private keys.
- Forwarded host ports loopback-only. Draft uses SSH 2222, dashboard 8080,
  ctools 8765, Pi Web 30141. Refuse collisions without disturbing listeners.
- Explain outbound networking is allowed: VM isolation is not a hostile-code
  network jail, a database rollback mechanism, or authority to use credentials.

## Current state: unfinished, not a working delivered setup

- A new Git repository exists here on `main`, but has NO COMMITS and NO REMOTE.
  Nothing has been published. Many draft files are staged; inspect working tree
  as well as index, which are not identical.
- NixOS/Home Manager inputs have a generated `flake.lock`.
- Base configuration evaluation passed before the requested simplification.
  This is not proof that the applications work or the VM boots.
- Copied dotfiles, local Pi extension source, portable dashboard, launcher and
  regression tests exist. Public-source/secret audit is not complete.
- Custom application packaging in `tools/default.nix` is REJECTED and remains
  to be removed, along with its references and copied npm lockfiles.
- `programs.nix-ld` and the custom patched AoE packaging are also to be removed.
- Old package builds failed. Their fixes must not be mistaken for an accepted
  design. No newly configured VM has booted.
- Launcher tests use stubbed host commands; dashboard link tests passed locally.
  Neither is a real host/KVM/systemd lifecycle acceptance test.
- Debian's `nix-bin` and `nix-setup-systemd` were installed here for verification;
  the Nix daemon is running and Phil was added to `nix-users`. No new Home
  Manager configuration was activated on this machine. `/dev/kvm` is unavailable
  inside this VM. Do not touch unrelated services while testing.

## Package availability fact to resolve honestly

At the pinned Nixpkgs revision, `pkgs.pi-coding-agent` exists (0.75.4), while the
source VM has 1.3.0. `ctxttools`/ctools is not present as a top-level package or
`python3Packages.ctxttools` at that revision. Do not silently downgrade Pi or
pretend every npm/Python package is automatically a Nixpkgs attribute.

A top-level Nix declaration can arrange an ordinary guest-side installation
without importing old lockfiles. Native Nix packaging and post-boot installation
are different mechanisms. Explain the choice accurately; do not invent more
custom packaging to avoid discussing a genuine blocker.

## Implementation sequence

1. Remove the rejected packaging/workarounds and stale references from the flake,
   host config, Home Manager config and README. Preserve the independent sources.
2. Use existing Nixpkgs packages for the base/development tools. Represent Pi and
   ctools setup simply, with no imported npm closure. Let Pi own its extensions.
   If that cannot work through supported mechanisms, report the exact blocker.
3. Connect dependent user services to successful guest application setup. The
   static dashboard should not depend on agent authentication/model access.
4. Run source tests and evaluate/build the actual configuration. Report real
   failures, not speculative package/platform concerns. Stop before adding any
   compatibility workaround without the owner's decision.
5. Boot an isolated test VM, preserving current ports/services. Check SSH,
   configuration activation, tool installation, dashboard/ctools/Pi Web, clean
   shutdown and persistent state. No paid model calls. If host KVM acceptance
   cannot be performed here, state that precisely and provide host commands.
6. Audit all files intended for the PUBLIC repository. Review copied configs,
   third-party licences and source provenance. No auth/session/model secrets.
7. Commit and publish the public `philvernon/sandbox-config` repository; verify
   public visibility and that the remote commit matches the delivered commit.
   Do not label unfinished or unverified work complete. README must reflect what
   actually works, plus concrete remaining acceptance limitations.

This is the implementation/handoff plan, not evidence that the implementation
has been completed. Prefer this document and the owner's latest instructions
when the draft README or source code disagrees.
