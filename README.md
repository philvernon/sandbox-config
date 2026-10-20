# Agent sandbox

Set up a NixOS coding-agent VM on an x86_64 Linux host. Development tools,
terminal/editor configuration and agent tools are listed in [SOFTWARE.md](SOFTWARE.md).

## Prepare the Arch host

Install the host packages and enable the Nix daemon:

```bash
sudo pacman -S --needed nix openssh git
sudo systemctl enable --now nix-daemon.service
loginctl enable-linger "$USER"
```

Run the sandbox as your regular user with `/dev/kvm` access. To grant access,
run `sudo usermod -aG kvm "$USER"`, then log out and back in.

Set the following in `~/.config/nix/nix.conf`, creating the directory and file
if needed:

```ini
experimental-features = nix-command flakes
```

## Configure and start

```bash
git clone https://github.com/philvernon/sandbox-config.git
cd sandbox-config
```

Set VM resources in `hosts/sandbox.nix` before the first launch. Defaults are
4 CPUs, 6 GB RAM and an 80 GB sparse guest disk. For a smaller VM, set `cores = 2`,
`memorySize = 4096` and `diskSize = 20480`.

Reserve additional host storage for Nix packages and the private store image,
then start the VM:

```bash
nix run .#sandbox
```

The first launch downloads/builds the VM and installs applications automatically.
Pi and editor plugins install through their package managers.

## Connect

From the checkout on the host:

```bash
nix run .#sandbox -- ssh
```

Inside the guest, check application setup:

```bash
systemctl --user status sandbox-app-setup --no-pager
```

Authenticate GitHub with `gh auth login`, then authenticate Pi and Codex through
their login commands. Host credentials remain on the host.

## Open the web tools over SSH

Run this on your laptop, replacing `homelab` with the host's address. Keep the
terminal open while using the web tools:

```bash
ssh -N -L 18080:127.0.0.1:18080 -L 8765:127.0.0.1:8765 \
  -L 30141:127.0.0.1:30141 phil@homelab
```

Open these addresses in your laptop's browser:

- Dashboard: <http://127.0.0.1:18080>
- ctools: <http://127.0.0.1:8765>
- Pi Web: <http://127.0.0.1:30141>

Pi Web and ctools start after application setup completes. Forwarded ports bind
to loopback. The dashboard maps host port 18080 to guest port 8080. Startup stops
if a required host port is occupied. Keep the web interfaces private.

## Manage the VM

Run these from the checkout on the host:

```bash
nix run .#sandbox -- status
nix run .#sandbox -- logs
nix run .#sandbox -- stop
```

Run `nix run .#sandbox` to start it again, including after a host reboot.

The disk and SSH key are stored under
`${XDG_STATE_HOME:-~/.local/state}/nix-sandbox/main/`. Guest files, logins and edits
persist across restarts. Seeded dotfiles remain writable and are retained across
rebuilds. The VM has outbound network access; host files and credentials remain
outside the guest.
