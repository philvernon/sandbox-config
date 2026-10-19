return {
	"saghen/blink.cmp",
	version = "1.*",
	dependencies = {
		"L3MON4D3/LuaSnip",
	},
	opts = {
		keymap = {
			preset = "default",
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			["<CR>"] = { "accept", "fallback" },
		},
		appearance = {
			kind_icons = {
				Text = "󰉿",
				Method = "󰊕",
				Function = "󰊕",
				Constructor = "",
				Field = "󰜢",
				Variable = "󰆧",
				Class = "󰠱",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "",
				Color = "󰏘",
				File = "󰈙",
				Reference = "",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰏿",
				Struct = "",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "󰊄",
			},
		},
		snippets = { preset = "luasnip" },
		completion = {
			list = {
				selection = {
					preselect = false,
					auto_insert = false,
				},
			},
			menu = {
				border = "none",
				scrollbar = false,
				draw = {
					align_to = "none",
					padding = 0,
					columns = {
						{ "kind_icon" },
						{ "label", "label_description", gap = 1 },
						{ "source_name" },
					},
					components = {
						source_name = {
							text = function(ctx)
								local names = {
									LSP = "[LSP]",
									Snippets = "[Snippet]",
									Buffer = "[Buffer]",
									Path = "[Path]",
								}
								return names[ctx.source_name] or ("[" .. ctx.source_name .. "]")
							end,
							highlight = "BlinkCmpSource",
						},
					},
				},
			},
			documentation = {
				auto_show = true,
				window = { border = "none", scrollbar = false },
			},
			ghost_text = { enabled = true },
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		cmdline = { enabled = false },
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
