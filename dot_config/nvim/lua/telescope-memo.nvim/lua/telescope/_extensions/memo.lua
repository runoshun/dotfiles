local memo_builtin = require("telescope._extensions.memo_builtin")

return require("telescope").register_extension({
	exports = {
		live_grep = memo_builtin.live_grep,
		list = memo_builtin.make_list({ "list", "--format", "{{.File}}" .. string.char(9) .. "{{.Title}}" }),
		list_todo = memo_builtin.make_list({ "todo", "-vim" }),
	},
})
