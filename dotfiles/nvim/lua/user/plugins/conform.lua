return {
	"stevearc/conform.nvim",
	opts = {
		formatters = {
			-- 	prettierd = {
			-- 		env = {
			-- 			PRETTIERD_DEFAULT_CONFIG = vim.fn.expand("~/.config/nvim/utils/.prettierrc"),
			-- 		},
			-- 	},
		},
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform will run multiple formatters sequentially
			python = { "isort", "black" },
			-- Use a sub-list to run only the first available formatter
			javascript = { "prettierd", "prettier" },
			vue = { "prettierd", "prettier" },
			scss = { "prettierd", "prettier" },
			typescript = { "prettierd", "prettier" },
			rust = { "rustfmt" },
			go = { "goimports", "gofumpt" },
			html = { "prettierd" },
			sql = { "pg_format" },
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				-- format with conform and store response
				local didConformFormat = require("conform").format({ bufnr = args.buf })

				-- If conform format was unsuccessful use LSP format
				if didConformFormat == false then
					local buf_clients = vim.lsp.get_clients()

					-- Check LSP clients that support formatting
					for _, client in pairs(buf_clients) do
						if client:supports_method("textDocument/formatting", args.buf) then
							vim.lsp.buf.format({ async = false })
						end
					end
				end
			end,
		})
	end,
}
