return {
	"folke/sidekick.nvim",
	config = function(_, opts)
		require("sidekick").setup(opts)
		local ok, integration = pcall(require, "pi-sessions.sidekick")
		if ok then
			integration.setup()
		end
	end,
	opts = {
		-- add any options here
		cli = {
			win = {
				keys = {
					prompt = { "<leader>ap", "prompt", mode = "n", desc = "insert prompt or context" },
					toggle_n = {
						"<c-p>",
						"blur",
						mode = "nt",
					},
					vsplit = {
						"<leader>s",
						function()
							vim.cmd.vnew()
						end,
						mode = "n",
					},
					hsplit = {
						"<leader>S",
						function()
							vim.cmd.new()
						end,
						mode = "n",
					},
					host_files = {
						",f",
						function()
							require("telescope.builtin").find_files({ hidden = true })
						end,
						mode = "t",
						desc = "Find files",
					},
					host_vsplit = {
						",v",
						function()
							vim.cmd.vnew()
						end,
						mode = "t",
						desc = "Vertical split",
					},
					host_hsplit = {
						",s",
						function()
							vim.cmd.new()
						end,
						mode = "t",
						desc = "Horizontal split",
					},
					host_tab = {
						",t",
						function()
							vim.cmd.tabnew()
						end,
						mode = "t",
						desc = "New tab",
					},
					host_close = {
						",q",
						function()
							vim.cmd.close()
						end,
						mode = "t",
						desc = "Close window",
					},
					nav_left = { "<c-h>", "nav_left", expr = true, desc = "navigate to the left window" },
					nav_down = { "<c-j>", "nav_down", expr = true, desc = "navigate to the below window" },
					nav_up = { "<c-k>", "nav_up", expr = true, desc = "navigate to the above window" },
					nav_right = { "<c-l>", "nav_right", expr = true, desc = "navigate to the right window" },
				},
				split = {
					width = 0, -- set to 0 for default split width
					height = 0, -- set to 0 for default split height
				},
			},
			picker = "telescope",
			mux = {
				backend = "tmux",
				enabled = true,
				create = "terminal",
			},
		},
	},
	keys = {
		{
			"<tab>",
			function()
				-- if there is a next edit, jump to it, otherwise apply it if any
				if not require("sidekick").nes_jump_or_apply() then
					return "<Tab>" -- fallback to normal tab
				end
			end,
			expr = true,
			desc = "Goto/Apply Next Edit Suggestion",
		},
		{
			"<c-p>",
			function()
				require("sidekick.cli").focus()
			end,
			desc = "Sidekick Focus",
			mode = { "n", "t", "i", "x" },
		},
		{
			"<leader>as",
			function()
				require("sidekick.cli").select({ filter = { installed = true } })
			end,
			-- Or to select only installed tools:
			-- require("sidekick.cli").select({ filter = { installed = true } })
			desc = "Select CLI",
		},
		{
			"<leader>ad",
			function()
				require("sidekick.cli").close()
			end,
			desc = "Detach a CLI Session",
		},
		{
			"<leader>at",
			function()
				require("sidekick.cli").send({ msg = "{this}" })
			end,
			mode = { "x", "n" },
			desc = "Send This",
		},
		{
			"<leader>af",
			function()
				require("sidekick.cli").send({ msg = "{file}" })
			end,
			desc = "Send File",
		},

		{
			"<leader>av",
			function()
				require("sidekick.cli").send({ msg = "{selection}" })
			end,
			mode = { "x" },
			desc = "Send Visual Selection",
		},
		{
			"<leader>ap",
			function()
				require("sidekick.cli").prompt()
			end,
			mode = { "n", "x" },
			desc = "Sidekick Select Prompt",
		},
		{
			"<leader>a.",
			function()
				require("sidekick.cli").toggle()
			end,
			desc = "Sidekick Toggle CLI",
		},
	},
}
