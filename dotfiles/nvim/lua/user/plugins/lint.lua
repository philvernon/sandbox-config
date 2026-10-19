return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("lint").linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			vue = { "eslint_d" },
		}

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
