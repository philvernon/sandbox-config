return {
	"L3MON4D3/LuaSnip",
	build = "make install_jsregexp",
	event = "InsertEnter",
	dependencies = {
		{ "rafamadriz/friendly-snippets" },
	},
	config = function()
		local ls = require("luasnip")
		local s = ls.snippet
		local sn = ls.snippet_node
		local isn = ls.indent_snippet_node
		local t = ls.text_node
		local i = ls.insert_node
		local f = ls.function_node
		local c = ls.choice_node
		local d = ls.dynamic_node
		local r = ls.restore_node
		local events = require("luasnip.util.events")
		local ai = require("luasnip.nodes.absolute_indexer")
		local fmt = require("luasnip.extras.fmt").fmt
		local extras = require("luasnip.extras")
		local m = extras.m
		local l = extras.l
		local rep = extras.rep
		local postfix = require("luasnip.extras.postfix").postfix

		require("luasnip.loaders.from_vscode").lazy_load()

		ls.add_snippets("vue", {
			s("translate", { t("{{ $t('"), i(1, "text"), t("') }}") }),
			s("translateStr", { t("$t('"), i(1, "text"), t("')") }),
			s("translatecount", { t("{{ $tc('"), i(1, "text"), t(", "), i(2, "count"), t("') }}") }),
		})

		ls.filetype_extend("typescript", { "javascript" })
		ls.filetype_extend("vue", { "vue" })
	end,
}
