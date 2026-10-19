local keymap = vim.keymap.set
vim.api.nvim_create_augroup("rust_aucmds", { clear = true })

-- vim.api.nvim_create_autocmd("InsertLeave", {
-- 	pattern = "*.rs",
-- 	callback = function()
-- 		local curr_row = vim.api.nvim_win_get_cursor(0)[1]
--
-- 		vim.lsp.buf.code_action({
-- 			range = {
-- 				["start"] = { curr_row, 0 },
-- 				["end"] = { curr_row, 100 },
-- 			},
-- 			filter = function(x)
-- 				local result = string.match(x.title, "^%s*(%S+)%s+(%S+)%s+(%S+)")
-- 				print(result)
-- 				return result == "Rename"
-- 			end,
-- 			apply = true,
-- 		})
-- 	end,
-- })

local function run_rename_uppercase()
	local buf = vim.api.nvim_get_current_buf()
	local diagnostics = vim.diagnostic.get(buf)

	-- print("==========tart=========")
	for key, value in pairs(diagnostics) do
		if value.code == "non_upper_case_globals" then
			vim.lsp.buf.code_action({
				range = {
					["start"] = { value.lnum + 1, value.col + 1 },
					["end"] = { value.end_lnum + 1, value.end_col + 1 },
				},
				-- context = { only = { "quickfix" } },
				filter = function(x)
					local filter = false
					if value.code == "non_upper_case_globals" and value.source == "rust-analyzer" then
						local result = string.match(x.title, "^%s*(%S+)%s+(%S+)%s+(%S+)")
						if result == "Rename" then
							filter = true
						end
					end
					-- print(key)
					-- print(x.title)
					-- print(value.message)
					-- print(value.source)
					-- print(filter)
					return filter
				end,
				apply = true,
			})
		end
	end
end

keymap("n", "<leader>r", run_rename_uppercase, { noremap = true, silent = true, desc = "Rust fix" })

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.rs",
	callback = run_rename_uppercase,
})

-- for key, value in pairs(diagnostics_to_fix) do
-- print(key)
-- end
-- local diagnostics = vim.lsp.diagnostic.get()

-- local last_row = vim.api.nvim_buf_line_count(buf)
-- print(last_row)
-- -- vim.lsp.buf.code_action({ context = { diagnostics = diagnostics_to_fix }, apply = true })
-- vim.lsp.buf.code_action({
-- 	-- context = { diagnostics = diagnostics },
-- 	range = { ["start"] = { 0, 0 }, ["end"] = { last_row, 100 } },
-- 	filter = function(x)
-- 		print(x)
-- print(x.title)
-- local result = string.match(x.title, "^%s*(%S+)%s+(%S+)%s+(%S+)")
-- print(result)
-- return result == "Rename"

-- local check_capitalise_constants_diagnostic = string.match(x.title, "([^:]+)")
-- print(x.title)
-- if check_capitalise_constants_diagnostic == "convert the identifier to upper case" then
-- 	return true
-- end
-- end,
-- apply = true,
-- })
