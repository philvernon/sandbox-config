# Agent sandbox

A standalone **NixOS + Home Manager** configuration for Phil's always-on coding
sandbox. It uses NixOS's supported QEMU VM runner, supervised by a **systemd user
service on the host**. No ISO installation, Cockpit, libvirt, or NixOS host needed.
The supported host is **x86_64 Linux** (initial target: Arch Linux).

This is independent of the main dotconfig repository. It includes a frozen copy
of the working Debian sandbox's dotfiles, including its local Neovim edits.
It does **not** migrate projects, credentials, databases or agent histories.

**Validation status:** configuration evaluation, VM/launcher builds and source
checks passed. Full boot/application/lifecycle acceptance was deferred at the
owner's request; this is not a claim that every guest application has been run.

## Host prerequisites (Arch)

Install Nix and enable its daemon. The host remains Arch:

```bash
sudo pacman -S --needed nix openssh
sudo systemctl enable --now nix-daemon.service
```

Your user needs access to Nix and `/dev/kvm`. If the package's `nix-users` group
exists and you aren't in it, add yourself; likewise for the host's `kvm` group:

```bash
getent group nix-users
sudo usermod -aG nix-users,kvm "$USER"
# Log out and back in after changing groups.
```

Do not run the sandbox as root. Check `test -r /dev/kvm && test -w /dev/kvm` as
your own user. A working **user systemd manager** is also required. To let the VM
keep running after logout, enable lingering for your host account:

```bash
loginctl enable-linger "$USER"
```

Enable flakes once by adding this to `~/.config/nix/nix.conf` (create the directory
if needed; preserve any existing options):

```ini
experimental-features = nix-command flakes
```

Alternatively prefix each Nix command with
`nix --extra-experimental-features 'nix-command flakes'`.

## Build and start

```bash
git clone https://github.com/philvernon/sandbox-config.git
cd sandbox-config
nix run .#sandbox
```

Or without a checkout:

```bash
nix run github:philvernon/sandbox-config#sandbox
```

The first invocation downloads/builds the pinned software, creates a fresh
per-sandbox SSH key on the host, and starts the VM in the background. The runner
then creates an isolated Nix-store disk image; first boot can take several
minutes. It is not necessary to install NixOS manually inside the VM.

Defaults: **4 vCPUs, 6 GiB RAM, 80 GiB sparse writable disk**. The actual host disk
usage also includes downloaded Nix packages and the guest's separate store image;
leave generous free space. Hardware defaults are in `hosts/sandbox.nix`.

## Use and inspect it

```bash
nix run .#sandbox -- status
nix run .#sandbox -- logs
nix run .#sandbox -- ssh
nix run .#sandbox -- stop
```

The SSH command works once the guest's SSH service is ready; it doesn't silently
wait or retry. The username is `phil`. The guest has passwordless sudo for this
throwaway sandbox, but no password login or root SSH login.

Ordinary host commands work too:

```bash
systemctl --user list-units 'sandbox-*'
systemctl --user status sandbox-main.service
journalctl --user -u sandbox-main.service -f
systemctl --user stop sandbox-main.service
```

Stopping requests guest ACPI shutdown. Systemd allows 120 seconds, then terminates
only this unit if shutdown is stuck. Forced termination is not a database backup.
The service is transient: it survives terminal exit (and logout with lingering),
but **does not automatically start after a host reboot**. Start it again with
`nix run .#sandbox`. The guest's dashboard starts at boot. Pi Web and ctools start after the automatic
application setup succeeds.

### Web tools

Open these **on the host**:

| Tool | URL |
| --- | --- |
| Dashboard | <http://127.0.0.1:8080> |
| ctools history browser | <http://127.0.0.1:8765> |
| Pi Web | <http://127.0.0.1:30141> |

All forwarded host ports bind to **loopback only**, including SSH on 2222. A busy
port causes a clear refusal, not termination or adoption of another process.

From your laptop, tunnel through the host (replace `homelab` as appropriate):

```bash
ssh -N -L 8080:127.0.0.1:8080 -L 8765:127.0.0.1:8765 \
  -L 30141:127.0.0.1:30141 phil@homelab
```

Then open <http://127.0.0.1:8080> on the laptop. The dashboard links follow the
hostname you opened it with. Pi Web and ctools expose private sessions/control;
do not publish these unauthenticated interfaces to the internet. You can set
`PI_WEB_PASSWORD=...` in the guest's `~/.config/sandbox/pi-web.env` and restart
`systemctl --user restart pi-web`.

Tailscale is installed/enabled inside the guest but **not enrolled**. If you run
`sudo tailscale up`, you are deliberately adding another network access path;
review service authentication and tailnet ACLs first.

## What is included

- **Development:** Node 24/npm, pnpm, Rust/Cargo/rustfmt/clippy/rust-analyzer, Go,
  Python, uv, pipx, GCC, make, CMake, Ninja, pkg-config, SQLite, Postgres tools.
- **Terminal:** zsh, Powerlevel10k/Antidote configuration, tmux with Nixpkgs TPM,
  Neovim and its `lazy-lock.json`, sesh, yazi, ranger, fzf, fd, ripgrep,
  zoxide, bat, htop/btop, shellcheck, shfmt and the existing helper scripts.
- **Git/GitHub:** Git, GitHub CLI, HTTPS credential-helper integration. Git identity
  defaults to `Phil <philvernon@users.noreply.github.com>`; change it as desired.
- **Agents:** Pi 1.3.0, Pi Web 0.12.2, pi-muxr 0.4.4 and ctools 0.3.1 via
  automatic guest-side installation. Codex (0.146.0 at the pinned revision) and
  RTK (0.41.0) are native Nixpkgs packages. Pi uses its normal portable settings
  and manages its own packages.
- **Web:** the dark wireframe dashboard plus boot-started Pi Web and ctools, with
  ctools' MCP dependencies included. MCP registration is not silently added.

Nixpkgs and Home Manager are pinned in `flake.lock`. Nixpkgs-provided versions
can differ from the Debian source VM; Pi is deliberately not downgraded to the
older Pi package at this Nixpkgs revision.

Shell plugins managed by Antidote may download on first interactive use, and
Neovim's normal lazy.nvim/Mason workflow installs plugins/language servers on
first use. The Neovim lockfile and local edits are preserved. Its `pi-tools`
plugin now uses `philvernon/pi-tools` on GitHub at an explicit commit instead of
requiring a private local checkout. Tmux's shell path uses NixOS's zsh location.
TPM installs its declared plugins when tmux starts; yazi installs from its
`package.toml` through `ya pkg install`. Plugin source is not copied into this
repo. Plugin-manager downloads are not covered by the Nix package lock.

**Presence-only notes:** Agent Deck and Agent of Empires were found on the
original VM; they are not provisioned here. RTK is included because it has a
native Nixpkgs package. Agent Deck's previous self-update timer is not recreated.
Paperclip is **not installed or started** here. It was present but stopped on the source VM and was explicitly
deferred. No local-inference server or commerce application is provisioned.

## Automatic application installation

No manual application installation is required. Home Manager declares a boot-time
`sandbox-app-setup.service` running as `phil`, with Node/npm, Python/uv and build
tools supplied by Nix. It runs:

- `npm install --global` for the versions in `tools/npm-packages.txt`;
- `uv tool install --python python3 'ctxttools[mcp]==0.3.1'`;
- `ya pkg install` for yazi's existing package declarations.

Applications and dependencies live in writable guest `~/.local/` and `~/.pi/`,
not the Nix store. `tools/pi-settings.json` seeds Pi's writable settings on first
boot; Pi handles its packages normally. There is no extension installer, vendored
extension source or copied npm dependency tree. No inherited permissions or auth
settings are imported.
There are no custom npm/Python derivations, binary compatibility shims or
peer-dependency bypass flags.

This is **declaratively initiated post-boot installation**, not immutable Nix
packaging: top-level application versions are explicit, but their installers'
transitive dependency resolution and downloads are not locked by `flake.lock`.
First boot needs outbound network access. A successful setup records a revision;
later boots skip reinstallation while that revision and the tool commands remain
present. Changed setup declarations trigger setup again. Existing user dotfiles,
projects and authentication are not reset.

Pi Web and ctools have `Requires=`/`After=` dependencies on successful setup.
A failure is visible and leaves no success marker; it is not silently bypassed.
The independent static dashboard does not wait for setup or authentication.
To inspect setup **inside the guest**:

```bash
systemctl --user status sandbox-app-setup pi-web ctools-web local-dashboard
journalctl --user -u sandbox-app-setup -b --no-pager
```

After resolving an actual failure, retry with
`systemctl --user restart sandbox-app-setup pi-web ctools-web`. This is a recovery
command, not a normal installation step. Any incompatibility must be discussed
before adding a workaround.

## Authentication and private state

There are **no credentials in this public repo or guest image**. After connecting:

```bash
gh auth login
# gh is configured as Git's HTTPS credential helper.
# Authenticate Pi/Codex with their own supported login flows when you want them.
```

No model/provider defaults, API credentials, spending allowances, host GitHub
login, SSH-agent socket, or existing purchase permissions are carried over.
Installing an agent is not permission to spend money; sessions/workflows must be
started and authorised explicitly. GitHub SSH transport would require a separate
guest SSH key; the generated host-to-guest key is not a GitHub identity.

## Configuration vs writable state

```text
flake.nix / flake.lock   pinned build and app entry point
hosts/sandbox.nix       guest OS, packages, isolation, ports and SSH bootstrap
home/default.nix        Home Manager, first-boot dotfiles and user services
dotfiles/               copied working config, independent of the original repo
tools/                  automatic npm/uv setup and portable Pi settings
dashboard/              static page, hostname-aware links and tests
host/sandbox.sh         systemd launcher and lifecycle commands
tests/                  launcher regression checks
```

Host state is outside Git in
`${XDG_STATE_HOME:-~/.local/state}/nix-sandbox/main/`: `root.qcow2`, a generated
SSH keypair, known_hosts, runtime monitor socket and `runtime/store.img`. The
runner uses its supported `TMPDIR`/`USE_TMPDIR` controls to build the private
store image on disk, rather than filling a RAM-backed `/tmp`. Treat this state as
private. The same disk is reused after stop/start; config changes do not erase
projects. There is intentionally no automatic delete/reset command.

Home Manager seeds **writable** copies of dotfiles under
`~/.config/sandbox-dotfiles/` on first boot. Your normal config paths link there.
Later rebuilds don't clobber your editor/plugin experiments. To retain edits,
copy them back into this repo intentionally. The public repo is not a backup.
Changes to existing seeded files won't overwrite them on an existing disk;
a fresh disk gets the updated seed.

The VM does **not** mount the host home, checkout, Nix store, certificate store,
Docker socket, or SSH agent. It uses a separate Nix-store image and user-mode
networking. It can make outbound network connections, including to reachable
host/LAN services: this is **not** a hostile-code network jail. VM isolation also
does not undo guest file deletion or external actions.

## Verify and update

```bash
python3 -m unittest discover -s tests -v
node --test dashboard/test.mjs
nix flake check
nix build .#vm
```

`nix flake check` includes configuration evaluation and source tests, not a boot
or a paid model test. A boot and SSH/web checks are separate acceptance steps.
For slow boot testing without nested KVM, explicitly set `SANDBOX_ALLOW_TCG=1`
when starting; normal launch refuses missing KVM access.

Update locks deliberately, review changes, rebuild and restart. The runner boots
the configuration associated with its Nix build while preserving the writable
disk. It does not modify the host OS configuration or activate Home Manager on
the host. No changes to the original Debian services or dotconfig are required.

### Source snapshot

Dotfiles include the source VM's local Neovim changes, with `pi-tools` configured
from Phil's GitHub and tmux's shell path adjusted for NixOS. Pi handles its own
packages from portable settings. Dashboard links are portable. The original
dotconfig, projects and web services were not modified. Only personal
configuration is copied, not plugin source or dependency trees.
