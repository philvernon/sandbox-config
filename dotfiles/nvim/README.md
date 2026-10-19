# Neovim configuration

Lua-based Neovim configuration using lazy.nvim, a comma leader, native LSP configuration, automatic formatting and linting, Telescope/Neo-tree/Yazi navigation, Git tooling, DAP and terminal-based AI tooling.

Capitalised terms such as MUST, MUST NOT, SHOULD, SHOULD NOT and MAY are normative in the BCP 14 sense.

## Table of contents

- [Overview](#overview)
- [Configuration layout](#configuration-layout)
- [Conventions](#conventions)
- [Core behaviour](#core-behaviour)
- [Language tooling](#language-tooling)
- [Plugins](#plugins)
- [Keymaps](#keymaps)
  - [Modes and leader](#modes-and-leader)
  - [General](#general)
  - [Find, files, buffers and tabs](#find-files-buffers-and-tabs)
  - [Git, LSP and diagnostics](#git-lsp-and-diagnostics)
  - [Debugging](#debugging)
  - [AI and external tools](#ai-and-external-tools)
  - [Plugin-local mappings](#plugin-local-mappings)
  - [Filetype mappings](#filetype-mappings)
- [External requirements](#external-requirements)
- [Known caveats](#known-caveats)

## Overview

init.lua is deliberately small. It loads core options, bootstraps lazy.nvim, installs global mappings, loads local helpers then configures LSP.

The config is organised around these subsystems:

| Area | Behaviour |
| --- | --- |
| Editor | Relative numbers, system clipboard, persistent undo, two-space indentation, split-below/right |
| Plugin management | lazy.nvim imports every spec under lua/user/plugins |
| Completion | blink.cmp with LSP, LuaSnip, buffer and path sources |
| LSP | Native vim.lsp.config/vim.lsp.enable with Mason-managed servers |
| Formatting | Conform formats on write then falls back to LSP formatting |
| Linting | nvim-lint runs eslint_d for JavaScript, TypeScript and Vue |
| Search | Telescope handles files, grep, buffers, Git state and diagnostics |
| Files | Neo-tree provides an in-Neovim explorer; Yazi provides an external file manager |
| Git | Gitsigns, Neogit, Diffview and Gitlinker |
| Debugging | nvim-dap, mason-nvim-dap and nvim-dap-ui |
| UI | Catppuccin Mocha, Lualine, WhichKey, hlchunk and Outline |
| Notes/Markdown | render-markdown, bullets.vim, mkdnflow and zk |
| AI/CLI | Sidekick, pi-tools, pi-nvim and Neocrush |

## Configuration layout

| Path | Purpose |
| --- | --- |
| init.lua | Top-level load order |
| lua/user/options.lua | Core Vim options and leader |
| lua/user/plugins-lazy.lua | lazy.nvim bootstrap and plugin import |
| lua/user/plugins/ | Plugin specs and plugin-specific configuration |
| lua/user/keymaps.lua | General repository-defined keymaps |
| lua/user/lsp/ | LSP servers, Vue/TypeScript integration, Rust settings and LSP mappings |
| lua/extra.lua | Translate command and Godot project server bootstrap |
| after/ftplugin/ | Filetype-specific behaviour |
| lazy-lock.json | Pinned plugin revisions |

New plugin configuration SHOULD live under lua/user/plugins. Cross-plugin editor behaviour SHOULD live in lua/user/keymaps.lua or lua/user/lsp. Filetype-specific behaviour SHOULD live under after/ftplugin.

The commented user.godot-setup require in init.lua is not active and MUST NOT be assumed to run.

## Conventions

- The global and local leader MUST be comma (,).
- New custom mappings MUST NOT use backslash as a leader-like prefix.
- Repository-defined mappings SHOULD include a concise desc, preferably one or two words.
- Related leader mappings SHOULD use stable namespaces: f for find, b for buffers, t for tabs, g for code/Git, d for diagnostics and D for debugging.
- Plugin specs SHOULD remain declarative where practical.
- lazy-lock.json SHOULD be updated through lazy.nvim rather than edited manually.
- External commands introduced by the config SHOULD be documented in [External requirements](#external-requirements).
- Secrets and machine credentials MUST NOT be committed to this configuration.
- This keymap inventory MUST cover mappings explicitly defined by this repository. Plugin defaults MAY add mappings at runtime and are outside this inventory.

## Core behaviour

options.lua enables termguicolors, absolute and relative line numbers, smart case-sensitive search, persistent undo, cursorline, a permanent sign column, mouse support and the unnamedplus clipboard. Splits open below and to the right. Indentation uses two columns with expandtab enabled. The statusline is global.

Project-local configuration MAY be loaded through exrc, with secure enabled.

Markdown buffers set textwidth=80 and enable en_GB spelling.

extra.lua defines :Translate using the trans executable. It also detects project.godot in the current directory or its parent and starts a Neovim server at server.pipe when needed. The gdscript ftplugin connects Neovim's LSP client to Godot on GDScript_Port or port 6005.

## Language tooling

Mason-lspconfig ensures vue_ls, ts_ls, lua_ls, bashls, gopls and marksman are installed.

The configuration enables or configures:

| Server | Use |
| --- | --- |
| vtsls | JavaScript, TypeScript and Vue TypeScript support |
| vue_ls | Vue language support |
| yamlls | YAML |
| eslint | ESLint with LspEslintFixAll before writes |
| lua_ls | Lua/Neovim |
| marksman | Markdown |
| gopls | Go |
| bashls | Shell |
| html | HTML |
| cssls | CSS |
| sqls | SQL |
| efm | Enabled if available |
| jsonls | JSON |
| rustaceanvim | Rust tooling outside the generic LSP setup |

Vue uses the TypeScript plugin supplied by vue-language-server. vtsls and vue_ls are enabled together.

Conform MUST run first on BufWritePre. If Conform reports that it could not format, the config falls back to an attached LSP client that supports formatting.

| Filetype | Formatter order |
| --- | --- |
| Lua | stylua |
| Python | isort, black |
| JavaScript | prettierd, prettier |
| TypeScript | prettierd, prettier |
| Vue | prettierd, prettier |
| SCSS | prettierd, prettier |
| Rust | rustfmt |
| Go | goimports, gofumpt |
| HTML | prettierd |
| SQL | pg_format |

nvim-lint runs eslint_d for JavaScript, TypeScript and Vue on buffer entry, after writes, after leaving insert mode and after text changes.

blink.cmp provides LSP, LuaSnip, buffer and path completion. Tab and Shift-Tab cycle completion items, Enter accepts the selection and LuaSnip remains the snippet engine. LuaSnip loads friendly-snippets and adds Vue translation snippets.

## Plugins

Status describes how the plugin appears in this configuration, not whether its repository is maintained upstream.

| Plugin | Source | Status | Role |
| --- | --- | --- | --- |
| lazy.nvim | folke/lazy.nvim | Bootstrap | Plugin manager |
| mason.nvim | williamboman/mason.nvim | Active | Tool installer |
| mason-lspconfig.nvim | williamboman/mason-lspconfig.nvim | Active | Mason/LSP bridge |
| nvim-lspconfig | neovim/nvim-lspconfig | Active | LSP configs |
| rustaceanvim | mrcjkb/rustaceanvim | Active | Rust LSP |
| fidget.nvim | j-hui/fidget.nvim | Active | LSP progress |
| blink.cmp | saghen/blink.cmp | Active | Completion engine |
| LuaSnip | L3MON4D3/LuaSnip | Active | Snippets |
| friendly-snippets | rafamadriz/friendly-snippets | Active | Snippet library |
| conform.nvim | stevearc/conform.nvim | Active | Formatting |
| nvim-lint | mfussenegger/nvim-lint | Active | Linting |
| nvim-autopairs | windwp/nvim-autopairs | Active | Auto pairs |
| nvim-surround | kylechui/nvim-surround | Active | Surround editing |
| mini.comment | nvim-mini/mini.comment | Active | Commenting |
| Comment.nvim | numToStr/Comment.nvim | Disabled | Commenting |
| nvim-ts-context-commentstring | JoosepAlviste/nvim-ts-context-commentstring | Disabled dependency | Context comments |
| nvim-treesitter | nvim-treesitter/nvim-treesitter | Commented | Parser config |
| telescope.nvim | nvim-telescope/telescope.nvim | Active | Picker/search |
| telescope-luasnip.nvim | benfowler/telescope-luasnip.nvim | Active | Snippet picker |
| telescope-ui-select.nvim | nvim-telescope/telescope-ui-select.nvim | Active | vim.ui picker |
| plenary.nvim | nvim-lua/plenary.nvim | Active dependency | Lua utilities |
| trouble.nvim | folke/trouble.nvim | Active | Diagnostics UI |
| neo-tree.nvim | nvim-neo-tree/neo-tree.nvim | Active | File explorer |
| nui.nvim | MunifTanjim/nui.nvim | Active dependency | UI primitives |
| nvim-web-devicons | nvim-tree/nvim-web-devicons | Active dependency | Icons |
| yazi.nvim | mikavilpas/yazi.nvim | Active | Yazi bridge |
| outline.nvim | hedyhli/outline.nvim | Active | Symbol outline |
| toggleterm.nvim | akinsho/toggleterm.nvim | Active | Terminal |
| nvim-ufo | kevinhwang91/nvim-ufo | Active | Folding |
| promise-async | kevinhwang91/promise-async | Active dependency | UFO async |
| gitsigns.nvim | lewis6991/gitsigns.nvim | Active | Git hunks |
| neogit | NeogitOrg/neogit | Active | Git UI |
| diffview.nvim | sindrets/diffview.nvim | Active | Git diff UI |
| gitlinker.nvim | linrongbin16/gitlinker.nvim | Active | Git links |
| nvim-dap | mfussenegger/nvim-dap | Active | Debug adapter |
| mason-nvim-dap.nvim | jay-babu/mason-nvim-dap.nvim | Active | DAP installer |
| nvim-dap-ui | rcarriga/nvim-dap-ui | Active | Debug UI |
| nvim-nio | nvim-neotest/nvim-nio | Active dependency | Async UI support |
| catppuccin | catppuccin/nvim | Active | Theme |
| lualine.nvim | nvim-lualine/lualine.nvim | Active | Statusline |
| hlchunk.nvim | shellRaining/hlchunk.nvim | Active | Scope guides |
| which-key.nvim | folke/which-key.nvim | Active | Key hints |
| nvim-colorizer.lua | norcalli/nvim-colorizer.lua | Active | Colour preview |
| render-markdown.nvim | MeanderingProgrammer/render-markdown.nvim | Active | Markdown rendering |
| mini.nvim | nvim-mini/mini.nvim | Active dependency | Markdown dependency |
| bullets.vim | bullets-vim/bullets.vim | Active | Markdown bullets |
| mkdnflow.nvim | jakewvincent/mkdnflow.nvim | Active | Markdown navigation |
| zk | zk-org/zk-nvim | Active | Zettelkasten |
| toggle-checkbox.nvim | opdavies/toggle-checkbox.nvim | Active | Checkboxes |
| nvim-dbee | kndndrj/nvim-dbee | Active | Database UI |
| bufdelete.nvim | famiu/bufdelete.nvim | Active | Buffer deletion |
| sidekick.nvim | folke/sidekick.nvim | Active | AI CLI bridge |
| pi-tools | philvernon/pi-tools | GitHub plugin pinned in its spec | Pi CLI, session browser and Sidekick integration |
| pi-nvim | carderne/pi-nvim | Active | Pi editor/context integration |
| neocrush.nvim | taigrr/neocrush.nvim | Active | Crush bridge |
| glaze.nvim | taigrr/glaze.nvim | Active dependency | Binary manager |

## Keymaps

### Modes and leader

Leader is comma (,).

| Symbol | Mode |
| --- | --- |
| N | Normal |
| I | Insert |
| V | Visual |
| T | Terminal |
| P | Plugin-local |

### General

| Mode | Key | Action |
| --- | --- | --- |
| N | ,qq | Quit all |
| N | Left | Window left |
| N | Down | Window down |
| N | Up | Window up |
| N | Right | Window right |
| N | ,l | Quit |
| N | ,s | Vsplit |
| N | ,S | Hsplit |
| N | ,Tab | Next buffer |
| N | ,Shift-Tab | Prev buffer |
| N | ]e | Next quickfix |
| N | [e | Prev quickfix |
| N/V/I | ß | Save |
| N/V/I | Cmd-S | Save |
| N/V/I | Alt-S | Save |
| N | Ctrl-D | Page down |
| N | Ctrl-U | Page up |
| V | ,p | Keep paste |
| N | ,u | Reload |
| N | ,c | Vue script |
| N | ,v | Vue template |
| N | ,id | UUID |
| N | ,L | Translate |
| N | ,x | Checkbox |
| T | Esc | Normal mode |
| T | jk | Normal mode |

Ctrl-D and Ctrl-U recenter the cursor after moving.

### Find, files, buffers and tabs

| Mode | Key | Action |
| --- | --- | --- |
| N | Ctrl-F | Find files |
| N | to | Buffers |
| N | ,ft | Telescope |
| N | ,fb | Buffers |
| N | ,fg | Grep |
| N | ,fG | Git files |
| N | ,fh | Help |
| N | ,fc | Commits |
| N | ,fs | Git status |
| N | ,fd | Diagnostics |
| N | ,fr | Resume |
| N | Ctrl-T | Neo-tree |
| N | ,e | Files |
| N | ,bw | Buffer solo |
| N | ,bq | Delete buffer |
| N | ,? | Key hints |
| N | ,ta | New tab |
| N | ,tc | Close tab |
| N | ,to | Only tab |
| N | ,tn | Next tab |
| N | ,tp | Prev tab |
| N/V | ,- | Yazi file |
| N | ,cw | Yazi cwd |
| N | Ctrl-Up | Yazi resume |
| N | ,o | Outline |
| N | Ctrl-\\ | Terminal |
| N | zR | Open folds |
| N | zM | Close folds |

### Git, LSP and diagnostics

| Mode | Key | Action |
| --- | --- | --- |
| N | ,gd | Diff |
| N | ,gD | Diff dev |
| N | ,gs | Show |
| N | ,gS | Show dev |
| N | ,gb | Stage buffer |
| N | ,gh | Stage hunk |
| N | ,gg | Neogit |
| N/V | ,gy | Yank link |
| N/V | ,gY | Open link |
| N | ]c | Next hunk |
| N | [c | Prev hunk |
| N | gD | Declaration |
| N | gd | Definition |
| N | ,gi | Implementation |
| N | ,gl | Diagnostic |
| N | ,gr | References |
| N | K | Hover |
| N | ,gk | Signature |
| N | ,gf | Format |
| N/V | ,gn | Rename |
| N/V | ,ga | Actions |
| N | ,dq | Quickfix |
| N | ,ds | Diag show |
| N | ,dh | Diag hide |
| N | ,dd | Diag toggle |
| N | ,de | Diag enable |
| N | ]d | Next diag |
| N | [d | Prev diag |

### Debugging

| Mode | Key | Action |
| --- | --- | --- |
| N | ,Dc | Continue |
| N | ,Do | Step over |
| N | ,Di | Step in |
| N | ,DO | Step out |
| N | ,Db | Breakpoint |
| N | ,Dq | Clear breaks |
| N | ,DB | Condition |
| N | ,ui | Debug UI |

DAP includes JavaScript, TypeScript, TSX and Vue launch/attach configurations plus Chrome and Firefox adapter configuration.

### AI and external tools

#### Sidekick

| Mode | Key | Action |
| --- | --- | --- |
| N | Tab | Next edit |
| N/T/I/V | Ctrl-P | Focus CLI |
| N | ,as | Select CLI |
| N | ,ad | Detach CLI |
| N/V | ,at | Send this |
| N | ,af | Send file |
| V | ,av | Send selection |
| N/V | ,ap | Prompt |
| N | ,a. | Toggle CLI |

Sidekick uses tmux as its mux backend. Pi-specific Sidekick configuration lives in the local pi-tools plugin.

#### Pi sessions

| Mode | Key | Action |
| --- | --- | --- |
| N | ,aa | Pi session picker |
| Sidekick N | Ctrl-R | Pi session picker |
| Sidekick T | ,p | Pi session picker |
| Sidekick T | ,e | Pi session tree |
| Sidekick T | ,n | New Pi |

pi-tools is installed by lazy.nvim from `philvernon/pi-tools` at the commit in
`lua/user/plugins/pi-tools.lua`, with no separate local checkout required. Its Neovim module automatically prepends the repo's own bin/ directory so Sidekick uses the isolated `tmux -L agents` server, and it configures Pi as `pi --tui-mode fullscreen`. The plugin provides `:PiSessionBrowser`, the compatibility alias `:PiSesh` and `:PiClient`; `:PiSessions` remains owned by pi-nvim. The same repo also owns the `pia` CLI wrapper.

#### Neocrush

| Mode | Key | Action |
| --- | --- | --- |
| N | ,cc | Toggle |
| N | ,cf | Focus |
| N | ,cl | Logs |
| N | ,cx | Cancel |
| N | ,cr | Restart |
| N/V | ,cp | Paste |
| N | ,cvr | CVM releases |
| N | ,cvl | CVM local |

### Plugin-local mappings

These mappings apply only inside the relevant plugin UI or completion menu.

#### Telescope

| Mode | Key | Action |
| --- | --- | --- |
| P/N | p | Preview |
| P/N | Ctrl-F | Close |
| P/N | ] | Next layout |
| P/N | [ | Prev layout |
| P/N | gq | Quickfix |
| P/N | Ctrl-T | Trouble |
| P/I | Ctrl-F | Close |
| P/I | Ctrl-T | Trouble |

#### Neo-tree

| Mode | Key | Action |
| --- | --- | --- |
| P | Ctrl-T | Close |
| P | Esc | Close |
| P | Tab | Close |
| P | o | Parent |
| P | h | Collapse/up |
| P | l | Expand/open |

#### Completion

| Mode | Key | Action |
| --- | --- | --- |
| I | Tab | Next item |
| I | Shift-Tab | Prev item |
| I | Up | Prev item |
| I | Down | Next item |
| I | Ctrl-B | Docs up |
| I | Ctrl-F | Docs down |
| I | Ctrl-Space | Complete |
| I | Enter | Confirm |

#### Yazi

| Mode | Key | Action |
| --- | --- | --- |
| P | F1 | Help |

### Filetype mappings

| Filetype | Mode | Key | Action |
| --- | --- | --- | --- |
| Rust | N | ,r | Rust fix |

The Rust ftplugin also runs the same uppercase-rename code action automatically before writing a Rust buffer.

## External requirements

The configuration MAY start without every external tool installed, but the corresponding feature will not work.

| Tool | Used by |
| --- | --- |
| git | lazy.nvim bootstrap, Git plugins |
| trans | :Translate |
| yazi | yazi.nvim |
| tmux | Sidekick mux |
| pi | Sidekick Pi CLI |
| crush | Neocrush |
| node | JavaScript DAP adapters and several language tools |
| stylua | Lua formatting |
| isort, black | Python formatting |
| prettierd or prettier | JS/TS/Vue/SCSS formatting |
| rustfmt | Rust formatting |
| goimports, gofumpt | Go formatting |
| pg_format | SQL formatting |
| eslint_d | JS/TS/Vue linting |
| Godot | GDScript LSP connection |

Neovim MUST provide the vim.lsp.config and vim.lsp.enable APIs used by this configuration.

## Known caveats

- mason-lspconfig ensures ts_ls, while the Vue setup enables vtsls and vue_ls. vtsls MUST therefore be available by some other installation path if it is not managed by Mason here.
- nvim-ufo is declared both in its dedicated plugin file and in all.lua. The duplicate spec SHOULD be consolidated if the configuration is cleaned up.
- Comment.nvim is explicitly disabled while mini.comment is active. Its disabled dependency SHOULD NOT be treated as runtime functionality.
- nvim-treesitter is present only as commented configuration. Other plugins MAY still use Neovim's built-in Tree-sitter facilities or installed parsers.
