vim.filetype.add({
	extension = {
		jinja = "htmldjango",
		jinja2 = "htmldjango",
		j2 = "htmldjango",
	},
	pattern = {
		[".*%.html%.j2"] = "htmldjango",
		[".*%.html%.jinja"] = "htmldjango",
		[".*%.html%.jinja2"] = "htmldjango",
	},
})

return {}
