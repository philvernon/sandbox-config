# Agent sandbox

A NixOS coding-agent VM for an **x86_64 Linux host**, with development tools,
Phil's terminal/editor configs, Pi, Codex, Pi Web and ctools. Apps install
automatically; Pi and editor plugins use their normal package managers.
See [installed software](SOFTWARE.md).

## 1. Prepare your Arch host

Skip anything already configured:

```bash
sudo pacman -S --needed nix openssh git
sudo systemctl enable --now nix-daemon.service
loginctl enable-linger "$USER"
```

Your user needs `/dev/kvm` access. If missing, run
`sudo usermod -aG kvm "$USER"`, then log out and back in. Run the sandbox as your
normal user, not root.

Add this to `~/.config/nix/nix.conf` (create the directory/file if needed):

```ini
experimental-features = nix-command flakes
```

## 2. Start

```bash
git clone https://github.com/philvernon/sandbox-config.git
cd sandbox-config
nix run .#sandbox
```

First launch takes time to download/build and install applications.

Defaults: **4 CPUs, 6 GB RAM, 80 GB sparse guest disk**. For a small test, change
`cores = 2`, `memorySize = 4096` and `diskSize = 20480` in `hosts/sandbox.nix`
**before first launch**. The host needs extra space for Nix packages and the
private store image.

## 3. Connect

```bash
nix run .#sandbox -- ssh
```

Inside the guest, check automatic installation with:

```bash
systemctl --user status sandbox-app-setup --no-pager
```

Authenticate GitHub (`gh auth login`), Pi and Codex inside the guest when needed.
No credentials are copied from the host.

For web access from your laptop, leave this tunnel running (replace `homelab`):

```bash
ssh -N -L 18080:127.0.0.1:18080 -L 8765:127.0.0.1:8765 \
  -L 30141:127.0.0.1:30141 phil@homelab
```

- Dashboard: <http://127.0.0.1:18080>
- ctools: <http://127.0.0.1:8765>
- Pi Web: <http://127.0.0.1:30141>

Pi Web/ctools wait for application setup. Ports are loopback-only; host port
**8080 is untouched**. Busy ports cause refusal, not termination of other services.
Don't expose these interfaces publicly.

## 4. Manage

```bash
nix run .#sandbox -- status
nix run .#sandbox -- logs
nix run .#sandbox -- stop
```

Start again with `nix run .#sandbox`, including after a host reboot. The disk and
SSH key persist under `${XDG_STATE_HOME:-~/.local/state}/nix-sandbox/main/`.
The VM does not mount your host files or credentials, but it has outbound network
access. Logins and guest edits persist; existing seeded dotfiles aren't overwritten.

**Status:** configuration builds checked; full boot/runtime acceptance is still
in progress.
