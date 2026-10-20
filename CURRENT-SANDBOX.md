# Sandbox catalogue

Snapshot of this running sandbox (Debian 13), not the NixOS VM defined in this repo.
User-facing tools and configuration; excludes base OS libraries and project dependencies.
Installed/configured does not mean tested or currently running.

## Dev tools

- **Languages:** Node.js/npm/pnpm, Python/pip/venv/uv/uvx/pipx, Rust/rustup/Cargo, Go.
- **Build:** GCC/G++, Make, CMake, pkg-config, OpenSSL development headers, tree-sitter CLI.
- **Editors:** Neovim, Vim, nano.
- **Terminal/files:** zsh, bash, tmux, screen, sesh, Yazi/ya, ranger.
- **Navigation/search:** ripgrep, fd, fzf, zoxide, eza, bat, tree, less.
- **Git:** Git, GitHub CLI, direnv.
- **Data/docs:** SQLite, jq, Glow, Poppler tools, chafa.
- **Lint/format:** ShellCheck, Ruff, SQLFluff, yamllint, rustfmt, Clippy.
- **Language/debug servers (Mason):** Bash, Go, Lua, Markdown, TypeScript, Vue, JS debug adapter; Rust tools via rustup.
- **System/network:** btop, htop, curl, wget, rsync, OpenSSH, Tailscale, socat, tcpdump, traceroute, ethtool, speedtest-cli.
- **Archives:** tar, gzip, xz, zip/unzip, 7-Zip, zstd.
- **Headless display:** Xvfb.
- **Sandbox provisioning:** Nix; this repo's NixOS/Home Manager VM configuration.

## Config

- **Shell:** `~/.zshrc`, `~/.zsh_plugins.txt`, `~/.p10k.zsh`; Antidote, Powerlevel10k, Oh My Zsh git/docker/docker-compose/extract/rust plugins, completions, fzf-tab, autopair, autosuggestions, syntax highlighting, zsh-defer.
- **tmux:** `~/.config/tmux/`, `~/.tmux.conf`; TPM, sensible, Catppuccin, ssh-split, resurrect, continuum, yank, suspend.
- **Sessions/helpers:** `~/.config/sesh/`; `copy`, `tmux-name-session`, `tmux-open-sessions`, `tmux-sesh` in `~/.local/bin/`.
- **File managers:** `~/.config/yazi/` (smart-enter, Catppuccin Mocha), `~/.config/ranger/`.
- **Neovim:** `~/.config/nvim/`; lazy.nvim, Mason, LSP, Treesitter, blink.cmp, LuaSnip, Conform, nvim-lint.
- **Neovim navigation/UI:** Telescope, neo-tree, outline, trouble, which-key, lualine, Catppuccin, folding, colour/highlight helpers, Yazi, toggleterm.
- **Neovim workflows:** Neogit, Gitsigns, Diffview, Gitlinker, DAP/UI, DBee, rustaceanvim, Markdown/rendering/notes plugins; full plugin list in `dotfiles/nvim/lazy-lock.json`.
- **Git/GitHub:** `~/.gitconfig`, `~/.config/gh/` (credentials not catalogued).
- **User service definitions:** local dashboard, Pi Web, ctools Web, Paperclip, Agent Deck auto-update service/timer in `~/.config/systemd/user/`.
- **Repo copies:** `dotfiles/`; VM definitions in `flake.nix`, `hosts/`, `home/`, `host/`, `tools/`; dashboard in `dashboard/`. These are not proof of live sandbox state.

## Agent tools

- **Pi:** `@earendil-works/pi-coding-agent`; settings/packages in `~/.pi/agent/settings.json`.
- **Pi interfaces:** Pi Web (`@agegr/pi-web`), pi-muxr (`@yuriteixeira/pi-muxr`).
- **Other agents:** Codex (`@openai/codex`), Crush (`~/go/bin/crush`).
- **Agent/session managers:** Agent Deck (`agent-deck`), Agent of Empires (`aoe`); both present here regardless of their exclusion from the VM config.
- **Paperclip:** `paperclipai`, `~/.paperclip/`, user service definition; present here, not included in the VM config.
- **Conversation tools:** `ctxttools` via uv; `ccat`, `cconnect`, `ccopy`, `cdir`, `cdu`, `cextract`, `cgrep`, `crecover`, `crm`, `ctools-mcp`, `ctools-web`.
- **Token reduction:** RTK (`rtk`), Pi RTK optimizer.
- **Pi packages — interaction:** pi-vim, pi-catppuccin, pi-tab-focus, pix-footer, pi-tool-display, rpiv-ask-user-question, rpiv-todo, pi-permission-system.
- **Pi packages — capabilities:** context-mode, pi-lens, pi-web-access, pi-rtk-optimizer, pi-muxr, design-playbook, ecc-universal.
- **Pi packages — workflows/skills:** pi-dynamic-workflows, `philvernon/pi-workflows`, `obra/superpowers`.
- **Local Pi extensions:** `agent-deck.ts`, `pi-permission-system`, `pi-rtk-optimizer`, `subagent`, `tools.ts`, `ui.ts` in `~/.pi/agent/extensions/` (not copied into the VM config).
- **Pi workflows:** echo, plan-implement, practice-shop in `~/.pi/agent/workflows/`.
- **MCP configuration:** context-mode, Penpot in `~/.pi/agent/mcp.json`.
- **Editor integrations:** pi-nvim, neocrush.nvim, sidekick.nvim in Neovim.
- **Agent configuration:** `~/.pi/`, `~/.codex/`, `~/.claude/`, `~/.pi-muxr/`, `~/.pi-lens/`, `~/.config/agent-deck/`, `~/.config/agent-of-empires/`.

Keep this list updated when adding/removing tools or changing configuration. Record VM inclusion separately; don't remove a tool from this catalogue just because it isn't migrated.
