# Software

Configured for the sandbox guest; not a live installation report.

## System & development

- **OS:** NixOS + Home Manager.
- **Terminal:** zsh, Powerlevel10k, Antidote, tmux/TPM, sesh.
- **Editor/files:** Neovim (lazy.nvim, Mason, pi-tools), yazi, ranger.
- **Languages:** Node.js 24/npm/pnpm, Python/uv/pipx, Rust/Cargo, Go.
- **Build tools:** GCC, Make, CMake, Ninja, pkg-config, OpenSSL; Rust formatting/lint/LSP tools.
- **Git/data:** Git, GitHub CLI, SQLite, PostgreSQL tools.
- **Utilities:** ripgrep, fd, fzf, zoxide, bat, btop, htop, ShellCheck, shfmt, curl/wget, archive tools.
- **Services:** SSH, Tailscale (fresh login required), local web dashboard.

## Agent tools

- **Pi:** coding agent; packages managed through its portable settings.
- **Pi Web:** browser interface for Pi.
- **pi-muxr:** Pi terminal/session tooling.
- **Codex:** OpenAI coding CLI.
- **ctools:** conversation-history CLI, web browser and MCP support.
- **RTK:** reduces command-output tokens.

Pi, Pi Web, pi-muxr and ctools install automatically at guest boot via npm/uv.
