local google_translate = function(args)
	local lang = args["args"]

	if lang == "" then
		lang = vim.fn.expand("%:t:r")
	end

	vim.api.nvim_command('normal! 0f:wvi"y')

	local selected_text = vim.fn.getreg('"')

	local translation =
			vim.fn.system("trans -brief :" .. lang .. " " .. vim.fn.shellescape(selected_text) .. " | tr -d '\n'")
	vim.fn.setreg('"', translation)
	vim.api.nvim_command('normal vi"""p')
end

vim.api.nvim_create_user_command("Translate", google_translate, { nargs = "?" })

-- paths to check for project.godot file
local paths_to_check = { '/', '/../' }
local is_godot_project = false
local godot_project_path = ''
local cwd = vim.fn.getcwd()

-- iterate over paths and check
for key, value in pairs(paths_to_check) do
	if vim.uv.fs_stat(cwd .. value .. 'project.godot') then
		is_godot_project = true
		godot_project_path = cwd .. value
		break
	end
end

-- check if server is already running in godot project path
local is_server_running = vim.uv.fs_stat(godot_project_path .. '/server.pipe')
-- start server, if not already running
if is_godot_project and not is_server_running then
	vim.fn.serverstart(godot_project_path .. '/server.pipe')
end
