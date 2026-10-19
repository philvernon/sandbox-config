return {
	"williamboman/mason.nvim",
	build = ":MasonUpdate",
	event = "VeryLazy",
	config = function()
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})
	end,
}
