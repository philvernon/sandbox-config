return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		vim.opt.termguicolors = true

		require("catppuccin").setup({
			flavor = "mocha",
			integrations = {
				blink_cmp = true,
				gitsigns = true,
				neo_tree = true,
				treesitter = true,
				telescope = true,
				mason = true,
				markdown = true,
				which_key = true,
				lsp_trouble = true,
				render_markdown = true,
				nvim_tree = {
					enabled = true,
					show_root = false,
					transparent_panel = false,
				},
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
				},
			},
		})

		vim.cmd.colorscheme("catppuccin")

		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "catppuccin",
			callback = function()
				vim.diagnostic.config({
					underlines = true,
					signs = true,
					update_in_insert = false,
					severity_sort = true,
					underline = true,
				})
			end,
		})
	end,
}
