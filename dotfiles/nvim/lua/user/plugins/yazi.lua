return
---@type LazySpec
{
	"mikavilpas/yazi.nvim",
	version = "*", -- use the latest stable version
	event = "VeryLazy",
	dependencies = {
		{ "nvim-lua/plenary.nvim", lazy = true },
	},
	keys = {
		{
			"<leader>-",
			mode = { "n", "v" },
			"<cmd>Yazi<cr>",
			desc = "Open yazi at the current file",
		},
		{
			"<leader>cw",
			"<cmd>Yazi cwd<cr>",
			desc = "Open the file manager in nvim's working directory",
		},
		{
			"<c-up>",
			"<cmd>Yazi toggle<cr>",
			desc = "Resume the last yazi session",
		},
	},
	---@type YaziConfig | {}
	opts = {
		open_for_directories = true,
		yazi_floating_window_border = "none",
		yazi_floating_window_winblend = 0,
		floating_window_scaling_factor = 0.6,
		highlight_hovered_buffers_in_same_directory = false,
		set_keymappings_function = function(bufnr, config, context)
			vim.keymap.set("t", ":", [[<C-\><C-n>:]], {
				buffer = bufnr,
			})
		end,
		keymaps = {
			show_help = "<f1>",
		},
		hooks = {
			yazi_opened = function(_, bufnr)
				vim.api.nvim_set_hl(0, "YaziFloat", {
					bg = "#181825",
				})
				local win = vim.fn.bufwinid(bufnr)
				if win ~= -1 then
					vim.api.nvim_set_option_value(
						"winhighlight",
						"Normal:YaziFloat,NormalFloat:YaziFloat,FloatBorder:YaziFloatBorder",
						{ win = win }
					)
				end
			end,
		},
	},
	init = function()
		vim.g.loaded_netrwPlugin = 1
	end,
}
