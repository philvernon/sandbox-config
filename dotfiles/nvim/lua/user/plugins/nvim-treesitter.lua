return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",

		config = function()
			require("nvim-treesitter").install({
				"bash",
				"css",
				"scss",
				"go",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"rust",
				"typescript",
				"vue",
				"yaml",
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"bash",
					"css",
					"scss",
					"go",
					"html",
					"javascript",
					"json",
					"lua",
					"markdown",
					"rust",
					"typescript",
					"vue",
					"yaml",
				},
				callback = function() vim.treesitter.start() end,
			})
		end,
	},
}
