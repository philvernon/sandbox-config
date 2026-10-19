local function apply_markdown_highlights()
	local colors = require("catppuccin.palettes").get_palette()

	local highlights = {
		RenderMarkdownH1 = { fg = colors.surface1, bold = true },
		RenderMarkdownH2 = { fg = colors.surface1, bold = false },
		RenderMarkdownH3 = { fg = colors.surface1, bold = true },
		RenderMarkdownH4 = { fg = colors.surface1, bold = true },
		RenderMarkdownH5 = { fg = colors.surface1, bold = true },
		RenderMarkdownH6 = { fg = colors.surface1, bold = true },
		RenderMarkdownH1Bg = { bg = colors.crust },
		RenderMarkdownH2Bg = { bg = colors.mantle },
		RenderMarkdownH3Bg = { bg = colors.surface0 },
		RenderMarkdownH4Bg = { bg = colors.surface1 },
		RenderMarkdownH5Bg = { bg = colors.surface2 },
		RenderMarkdownH6Bg = { bg = colors.overlay0 },
		RenderMarkdownDash = { fg = colors.surface1 },
		RenderMarkdownBullet = { fg = colors.overlay1 },
		RenderMarkdownChecked = { fg = colors.overlay1 },
		RenderMarkdownUnchecked = { fg = colors.overlay1 },
		["@markup.heading.markdown"] = { fg = colors.text, bold = true },
		["@markup.heading.1.markdown"] = { fg = colors.text, bold = true },
		["@markup.heading.2.markdown"] = { fg = colors.text, bold = true },
		["@markup.heading.3.markdown"] = { fg = colors.text, bold = true },
		["@markup.heading.4.markdown"] = { fg = colors.text, bold = true },
		["@markup.heading.5.markdown"] = { fg = colors.text, bold = true },
		["@markup.heading.6.markdown"] = { fg = colors.text, bold = true },
		["@markup.link.markdown"] = { fg = colors.overlay1, underline = true },
		["@markup.link.label.markdown"] = { fg = colors.overlay1 },
		["@markup.list.markdown"] = { fg = colors.overlay1 },
		["@markup.quote.markdown"] = { fg = colors.overlay1 },
		["@markup.raw.markdown_inline"] = { fg = colors.text, bg = colors.surface0 },
		["@markup.strong.markdown_inline"] = { fg = colors.text, bold = true },
		MarkdownNormal = { fg = colors.subtext0 },
	}

	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			anti_conceal = { enabled = false },
			heading = {
				sign = false,
				border = true,
				left_pad = 2,
				position = "inline",
				icons = { "", "", "", "", "", "" },
			},
		},
		config = function(_, opts)
			require("render-markdown").setup(opts)
			apply_markdown_highlights()
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "catppuccin",
				callback = apply_markdown_highlights,
			})
		end,
	},
}
