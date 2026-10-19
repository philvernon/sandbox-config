return {
	"NeogitOrg/neogit",
	lazy = true,
	dependencies = {
		"sindrets/diffview.nvim",
		"nvim-telescope/telescope.nvim",
	},
	cmd = "Neogit",
	keys = {
		{ "<leader>gg", "<cmd>Neogit kind=vsplit<cr>", desc = "Neogit" },
	},
}
