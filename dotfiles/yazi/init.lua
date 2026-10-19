Header:children_add(function()
	if ya.target_family() ~= "unix" then
		return ""
	end

	return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. " "):fg("green"):bold()
end, 500, Header.LEFT)

function Entity:padding()
	return " "
end

function Linemode:padding()
	return ""
end

if os.getenv("YAZI_NVIM_ID") then
	rt.mgr.ratio = { 0, 3, 4 }
	ya.emit("hidden", { "hide" })
	print(th)
	th.app.overall = { bg = "#181825" }
end
