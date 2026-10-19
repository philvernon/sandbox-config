return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")

		-- local opts = {
		--   mode = "n", -- NORMAL mode
		--   -- prefix: use "<leader>f" for example for mapping everything related to finding files
		--   -- the prefix is prepended to every mapping part of `mappings`
		--   prefix = "<leader>f",
		--   buffer = true, -- Global mappings. Specify a buffer number for buffer local mappings
		--   silent = true, -- use `silent` when creating keymaps
		--   noremap = true, -- use `noremap` when creating keymaps
		--   nowait = false, -- use `nowait` when creating keymaps
		-- }
		--
		-- wk.register({}, opts)

		wk.setup({
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		})

		wk.add({
			{ "<leader>f", group = "Find" },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>t", group = "Tabs" },
			{ "<leader>g", group = "Code" },
			{ "<leader>d", group = "Diag" },
			{ "<leader>D", group = "Debug" },
			{ "<leader>a", group = "Sidekick" },
		})

		-- wk.register(mappings, opts)
	end,
}
