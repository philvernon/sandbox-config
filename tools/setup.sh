# Run as the guest user by sandbox-app-setup.service, never on the host.
set -euo pipefail
umask 077

export PATH="$HOME/.local/bin:$PATH"
export npm_config_prefix="$HOME/.local"
export UV_TOOL_DIR="$HOME/.local/share/uv/tools"
export UV_TOOL_BIN_DIR="$HOME/.local/bin"
# Use the Nix-provided Python, not an automatically downloaded interpreter.
export UV_PYTHON_DOWNLOADS=never

state="$HOME/.local/state/sandbox"
stamp="$state/app-setup-revision"
revision='@revision@'
mkdir -p "$state" "$HOME/.local/bin"
if [[ -f "$stamp" && "$(cat "$stamp")" == "$revision" ]] &&
   command -v pi pi-web pi-muxr ctools ctools-web >/dev/null; then
  echo 'Sandbox application setup is already current.'
  exit 0
fi
# Never retain a success marker across an interrupted or failed update.
rm -f "$stamp"

mapfile -t applications < '@npmPackages@'
npm install --global "${applications[@]}"
uv tool install --python python3 'ctxttools[mcp]==0.3.1'
ya pkg install

# Pi manages its own packages from its portable settings on normal startup.
printf '%s\n' "$revision" > "$stamp"
echo 'Sandbox application setup completed.'
