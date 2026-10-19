local opts = { silent = true }
-- local keymap = vim.api.nvim_set_keymap
local keymap = vim.keymap.set

local function leader(lhs, rhs, desc, mode)
	keymap(mode or "n", "<leader>" .. lhs, rhs, { silent = true, desc = desc })
end

-- GENERAL
leader("qq", "<cmd>wqa<CR>", "Quit all")
-- Better window navigation
keymap("n", "<Left>", "<C-w>h", opts)
keymap("n", "<Down>", "<C-w>j", opts)
keymap("n", "<Up>", "<C-w>k", opts)
keymap("n", "<Right>", "<C-w>l", opts)
leader("l", "<cmd>q<CR>", "Quit")
-- open split
leader("s", "<cmd>vsplit<CR>", "Vsplit")
leader("S", "<cmd>split<CR>", "Hsplit")
-- buffer
leader("<tab>", "<cmd>bn<CR>", "Next buffer")
leader("<s-tab>", "<cmd>bp<CR>", "Prev buffer")
-- quickfix
keymap("n", "]e", "<cmd>cnext<CR>", opts)
keymap("n", "[e", "<cmd>cprev<CR>", opts)
-- jk to exit insert mode
-- keymap("i", "jk", "<ESC>", opts)
-- keymap("i", "kj", "<ESC>", opts)
-- keymap("i", "jj", "<ESC>", opts)
-- keymap("i", "kk", "<ESC>", opts)
-- Map alt + s to save
keymap("n", "ß", "<cmd>update<CR>", opts)
keymap("v", "ß", "<C-C>:update<CR><ESC>", opts)
keymap("i", "ß", "<C-O>:update<CR><ESC>", opts)
-- Map super + s to save on linux
keymap("n", "<D-s>", "<cmd>update<CR>", opts)
keymap("v", "<D-s>", "<C-C>:update<CR><ESC>", opts)
keymap("i", "<D-s>", "<C-O>:update<CR><ESC>", opts)
-- Map Alt + s to save on linux in tmux (ffs)
keymap("n", "<M-s>", "<cmd>update<CR>", opts)
keymap("v", "<M-s>", "<C-C>:update<CR><ESC>", opts)
keymap("i", "<M-s>", "<C-O>:update<CR><ESC>", opts)
-- center ctrl d and u
keymap("n", "<C-d>", "<C-d>zz", opts)

keymap("n", "<C-u>", "<C-u>zz", opts)
-- paste over and keep in register
leader("p", '"_dP', "Keep paste", "x")
-- Update vim config
leader("u", "<cmd>so ~/.config/nvim/init.lua<CR>", "Reload")
-- UTIL
-- Vue
leader("c", "/script<CR>ggn", "Vue script")
leader("v", "/template<CR>ggn", "Vue template")
-- PLUGINS
-- Telescope
keymap("n", "<C-f>", "<cmd>Telescope find_files hidden=true<CR>", opts)
keymap("n", "to", "<cmd>Telescope buffers<CR>", opts)
leader("ft", "<cmd>Telescope<CR>", "Telescope")
leader("fb", "<cmd>Telescope buffers<CR>", "Buffers")
leader("fs", "<cmd>Telescope live_grep<CR>", "Grep")
leader("fG", "<cmd>Telescope git_files<CR>", "Git files")
leader("fh", "<cmd>Telescope help_tags<CR>", "Help")
leader("fc", "<cmd>Telescope git_commits<CR>", "Commits")
leader("fg", "<cmd>Telescope git_status<CR>", "Git status")
leader("fd", "<cmd>Telescope diagnostics<CR>", "Diagnostics")
leader("fr", "<cmd>Telescope resume<CR>", "Resume")

-- neo-tree
keymap("n", "<C-t>", "<cmd>Yazi toggle float<CR>", opts)
leader("es", "<cmd>Neotree reveal<CR>", "Files")
leader("el", "<cmd>Neotree left<CR>", "Open left")
leader("ef", "<cmd>Neotree float<CR>", "Open float")
-- buffer
leader("bw", "<cmd>w|%bd|e#|bd#<CR>", "Solo")
leader("bq", "<cmd>Bdelete<CR>", "Delete")
-- whichkey
leader("?", "<cmd>WhichKey<CR>", "Keys")
-- exit terminal
keymap("t", "<C-n>", [[<C-\><C-n>]], opts)
-- tabby
leader("ta", "<cmd>$tabnew<CR>", "New")
leader("tc", "<cmd>tabclose<CR>", "Close")
leader("to", "<cmd>tabonly<CR>", "Only")
leader("tn", "<cmd>tabn<CR>", "Next")
leader("tp", "<cmd>tabp<CR>", "Previous")

-- UUID Gen
leader("id", '<cmd>exe ":normal i" . system("uuidgen | tr -d \'\\n\'")<CR>', "UUID")

-- git
leader("gd", "<cmd>Gitsigns diffthis<CR>", "Diff")
leader("gD", "<cmd>Gitsigns diffthis develop<CR>", "Diff dev")
leader("gs", "<cmd>Gitsigns show ", "Show")
leader("gS", "<cmd>Gitsigns show develop<CR>", "Show dev")
leader("gb", "<cmd>Gitsigns stage_buffer<CR>", "Stage buffer")
leader("gh", "<cmd>Gitsigns stage_hunk<CR>", "Stage hunk")

-- translate
leader("L", "<cmd>Translate<CR>", "Translate")
-- checkboxes
leader("x", "<cmd>lua require('toggle-checkbox').toggle()<CR>", "Checkbox")

leader("m", "<cmd>RenderMarkdown toggle<CR>", "Toggle MD Render")
