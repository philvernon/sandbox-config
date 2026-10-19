return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "catppuccin/nvim", name = "catppuccin" },
	config = function()
		local clrs = require("catppuccin.palettes").get_palette()
		if clrs == nil then print("catpuccin not working"); return end

		local lualine = require("lualine")
		local colors = { bg = "#202328", fg = "#bbc2cf", yellow = "#ECBE7B", cyan = "#008080", darkblue = "#081633", green = "#98be65", orange = "#FF8800", violet = "#a9a1e1", magenta = "#c678dd", blue = "#51afef", red = "#ec5f67" }

		local mode_names = { n = "N", no = "N?", nov = "N?", noV = "N?", ["no\22"] = "N?", niI = "Ni", niR = "Nr", niV = "Nv", nt = "Nt", v = "V", vs = "Vs", V = "V_", Vs = "Vs", ["\22"] = "^V", ["\22s"] = "^V", s = "S", S = "S_", ["\19"] = "^S", i = "I", ic = "Ic", ix = "Ix", R = "R", Rc = "Rc", Rx = "Rx", Rv = "Rv", Rvc = "Rv", Rvx = "Rv", c = "C", cv = "Ex", r = "...", rm = "M", ["r?"] = "?", ["!"] = "!", t = "T" }

		local mode_colors = { n = clrs.lavender, no = clrs.lavender, i = clrs.green, ic = clrs.green, t = clrs.green, v = clrs.flamingo, V = clrs.flamingo, ["\22"] = clrs.flamingo, R = clrs.maroon, Rv = clrs.maroon, s = clrs.maroon, S = clrs.maroon, ["\19"] = clrs.maroon, c = clrs.peach, cv = clrs.peach, ce = clrs.peach, r = clrs.teal, rm = clrs.teal, ["r?"] = clrs.mauve, ["!"] = clrs.green }

		local conditions = { buffer_not_empty = function() return vim.fn.empty(vim.fn.expand("%:t")) ~= 1 end, hide_in_width = function() return vim.fn.winwidth(0) > 80 end, check_git_workspace = function() local filepath = vim.fn.expand("%:p:h"); local gitdir = vim.fn.finddir(".git", filepath .. ";"); return gitdir and #gitdir > 0 and #gitdir < #filepath end }

		local disallow = { "packer", "neo-tree filesystem", "toggleterm" }
		local theme = { normal = { a = { bg = "None", gui = "bold" }, b = { bg = "None", gui = "bold" }, c = { bg = "None", gui = "bold" }, x = { bg = "None", gui = "bold" }, y = { bg = "None", gui = "bold" }, z = { bg = "None", gui = "bold" } }, insert = { a = { bg = "None", gui = "bold" }, b = { bg = "None", gui = "bold" }, c = { bg = "None", gui = "bold" }, x = { bg = "None", gui = "bold" }, y = { bg = "None", gui = "bold" }, z = { bg = "None", gui = "bold" } }, visual = { a = { bg = "None", gui = "bold" }, b = { bg = "None", gui = "bold" }, c = { bg = "None", gui = "bold" }, x = { bg = "None", gui = "bold" }, y = { bg = "None", gui = "bold" }, z = { bg = "None", gui = "bold" } }, replace = { a = { bg = "None", gui = "bold" }, b = { bg = "None", gui = "bold" }, c = { bg = "None", gui = "bold" }, x = { bg = "None", gui = "bold" }, y = { bg = "None", gui = "bold" }, z = { bg = "None", gui = "bold" } }, command = { a = { bg = "None", gui = "bold" }, b = { bg = "None", gui = "bold" }, c = { bg = "None", gui = "bold" }, x = { bg = "None", gui = "bold" }, y = { bg = "None", gui = "bold" }, z = { bg = "None", gui = "bold" } }, inactive = { a = { bg = "None", gui = "bold" }, b = { bg = "None", gui = "bold" }, c = { bg = "None", gui = "bold" }, x = { bg = "None", gui = "bold" }, y = { bg = "None", gui = "bold" }, z = { bg = "None", gui = "bold" } } }

		local config = { extensions = { "nvim-tree" }, globalstatus = true, options = { disabled_filetypes = { statusline = disallow, winbar = disallow, "Outline", "" }, component_separators = "", section_separators = "", theme = theme }, sections = { lualine_a = {}, lualine_b = {}, lualine_y = {}, lualine_z = {}, lualine_c = {}, lualine_x = {} }, inactive_sections = { lualine_a = {}, lualine_b = {}, lualine_y = {}, lualine_z = {}, lualine_c = {}, lualine_x = {} }, winbar = { lualine_c = { { "filename", color = { gui = "bold", fg = clrs.text }, padding = { left = 0, right = 0, bottom = 0, top = 0 }, symbols = { modified = "●", newfile = "" } } }, lualine_x = {} }, inactive_winbar = { lualine_a = {}, lualine_c = { { "filename", color = { gui = "bold", fg = clrs.surface2, bg = clrs.base }, padding = { left = 0, right = 0, bottom = 0, top = 0 }, symbols = { modified = "●", newfile = "" } } }, lualine_z = {} } }

		local function ins_left(component) table.insert(config.sections.lualine_c, component) end
		local function ins_right(component) table.insert(config.sections.lualine_x, component) end
		local function mode_to_color() return { fg = mode_colors[vim.fn.mode()] } end

		ins_left({ function() return "▊" end, color = mode_to_color, padding = { left = 0, right = 1 } })
		ins_left({ function() return mode_names[vim.fn.mode()] end, padding = { right = 1 } })

		local function fill_string_width(str) local tmp_str = str:gsub("+", ""):gsub("~", ""):gsub("-", ""); return string.format("%3s", tostring(tmp_str)) end

		ins_left({ "branch", icon = "", color = { fg = clrs.blue, gui = "bold" } })
		ins_left({ "filename", cond = conditions.buffer_not_empty, color = { fg = clrs.subtext0, gui = "bold" }, path = 1, shorting_target = 150 })
		ins_left({ "diff", symbols = { added = "+", modified = "~", removed = "-" }, fmt = fill_string_width, diff_color = { added = { fg = colors.green }, modified = { fg = colors.orange }, removed = { fg = colors.red } }, cond = conditions.hide_in_width })

		ins_right({ "diagnostics", sources = { "nvim_diagnostic" }, symbols = { error = "", warn = "", info = "", hint = "" }, diagnostics_color = { color_error = { fg = colors.red }, color_warn = { fg = colors.yellow }, color_info = { fg = colors.cyan } } })
		ins_right({ "filetype", color = { fg = clrs.subtext0 } })
		ins_right({ function() local clients = vim.lsp.get_clients(); if next(clients) == nil then return "" end; local msg = ""; for _, client in ipairs(clients) do msg = msg .. client.name .. " " end; return msg:gsub("%s+$", "") end, color = { fg = clrs.subtext0, gui = "bold" }, padding = 0 })
		ins_right({ "location", color = { fg = clrs.subtext0 } })
		ins_right({ function() return tostring(vim.api.nvim_buf_line_count(vim.fn.winbufnr(vim.g.statusline_winid))) end, color = { fg = clrs.subtext0 } })
		ins_right({ "progress", color = { fg = clrs.subtext0, gui = "bold" } })
		ins_right({ function() return " ▊" end, color = mode_to_color, padding = { left = 1 } })

		lualine.setup(config)
	end,
}
