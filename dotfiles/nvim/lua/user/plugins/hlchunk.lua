return {
	"shellRaining/hlchunk.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local clrs = require("catppuccin.palettes").get_palette()

		require("hlchunk").setup({
			chunk = {
				style = {
					{ fg = clrs.surface1 },
					{ fg = clrs.surface1 },
				},
				enable = true,
				chars = {
					right_arrow = "",
				},
				delay = 100,
				duration = 0,
			},
		})
	end,
}
