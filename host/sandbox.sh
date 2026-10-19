# Embedded by flake.nix in a writeShellApplication; not a standalone installer.
set -euo pipefail

unit=sandbox-main.service
state="${XDG_STATE_HOME:-$HOME/.local/state}/nix-sandbox/main"
action="${1:-start}"
if (( $# )); then shift; fi

case "$action" in
  status) exec systemctl --user status "$unit" ;;
  logs) exec journalctl --user -u "$unit" -f ;;
  stop) exec systemctl --user stop "$unit" ;;
  ssh)
    exec ssh -o IdentitiesOnly=yes -o ForwardAgent=no \
      -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile="$state/known_hosts" \
      -i "$state/id_ed25519" -p 2222 phil@127.0.0.1 "$@"
    ;;
  _poweroff)
    # ExecStop receives MAINPID from systemd. Request ACPI shutdown before
    # systemd's 120-second timeout falls back to terminating this unit only.
    if [[ -S "$state/monitor.sock" ]]; then
      printf 'system_powerdown\n' | socat -T 2 - "UNIX-CONNECT:$state/monitor.sock" || true
      while [[ -n "${MAINPID:-}" ]] && kill -0 "$MAINPID" 2>/dev/null; do sleep 1; done
    fi
    exit 0
    ;;
  start) ;;
  *) echo 'Usage: nix run .#sandbox -- [start|stop|status|logs|ssh [command]]' >&2; exit 2 ;;
esac

if (( $# )); then echo 'start takes no extra arguments' >&2; exit 2; fi
# QEMU_OPTS is expanded by the supported runner. Reject paths its argument
# syntax cannot represent safely instead of silently splitting them.
if [[ "$state" != /* || "$state" =~ [[:space:],] ]]; then
  echo 'Sandbox state path must be absolute and contain no whitespace or commas.' >&2
  exit 1
fi
systemctl --user show-environment >/dev/null
umask 077
mkdir -p "$state"
exec 9>"$state/launch.lock"
flock -n 9 || { echo 'Another sandbox start is in progress.' >&2; exit 1; }
if systemctl --user is-active --quiet "$unit"; then
  echo 'Sandbox is already running. Use: nix run .#sandbox -- ssh'
  exit 0
fi
if [[ -n "$(ss -H -ltn '( sport = :2222 or sport = :8080 or sport = :8765 or sport = :30141 )')" ]]; then
  echo 'A required host port (2222, 8080, 8765, 30141) is already in use; nothing started.' >&2
  exit 1
fi
if [[ ! -r /dev/kvm || ! -w /dev/kvm ]]; then
  if [[ "${SANDBOX_ALLOW_TCG:-0}" != 1 ]]; then
    echo 'KVM is not accessible. Give your host user KVM access, then log in again.' >&2
    echo 'For slow software-emulation testing only: SANDBOX_ALLOW_TCG=1 nix run .#sandbox' >&2
    exit 1
  fi
  echo 'Warning: using QEMU software emulation; this is much slower than KVM.' >&2
fi
if [[ ! -e "$state/id_ed25519" ]]; then
  ssh-keygen -q -t ed25519 -N '' -C sandbox-main -f "$state/id_ed25519"
fi
[[ -f "$state/id_ed25519.pub" ]] || { echo 'Sandbox public key is missing.' >&2; exit 1; }

# Keep the launcher and its full VM closure alive across host garbage collection.
# The normal entry point is the built Nix application, not this source file.
nix-store --add-root "$state/launcher" --indirect --realise "$(dirname "$(dirname "$0")")" >/dev/null

# The supported runner's private store image can exceed a RAM-backed /tmp.
# Give it a stable, disk-backed work directory through its supported controls.
mkdir -p "$state/runtime"
# Persistent paths are outside both Git and the Nix store. The private key is
# never passed to QEMU: the guest receives its public half via firmware config.
systemd-run --user --unit="$unit" --collect --service-type=exec \
  --description='NixOS agent sandbox' \
  --property="WorkingDirectory=$state" \
  --property="ExecStop=$0 _poweroff" \
  --property=TimeoutStopSec=120 --property=KillMode=mixed \
  --setenv="XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}" \
  --setenv="HOME=$HOME" \
  --setenv="NIX_DISK_IMAGE=$state/root.qcow2" \
  --setenv="TMPDIR=$state/runtime" --setenv='USE_TMPDIR=1' \
  --setenv="QEMU_OPTS=-fw_cfg name=opt/sandbox.ssh-key,file=$state/id_ed25519.pub -monitor unix:$state/monitor.sock,server=on,wait=off" \
  --setenv='QEMU_KERNEL_PARAMS=console=ttyS0' \
  --setenv='QEMU_NET_OPTS=' \
  '@vmRunner@'

echo 'VM starting. First boot creates an isolated Nix-store image and can take a while.'
echo 'Status: nix run .#sandbox -- status'
echo 'Console: nix run .#sandbox -- logs'
echo 'Connect when ready: nix run .#sandbox -- ssh'
echo 'Dashboard on the host: http://127.0.0.1:8080'
