local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local builtin = require("telescope.builtin")
local finders = require("telescope.finders")
local from_entry = require("telescope.from_entry")
local Path = require("plenary.path")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local utils = require("telescope.utils")

local M = {}

local sep = string.char(9)

local echo = function(msg, hl)
	vim.api.nvim_echo({ { "[telescope-memo] " .. msg, hl } }, true, {})
end

local function gen_from_memo(opts)
	local displayer = entry_display.create({
		separator = " : ",
		items = {
			{}, -- File
			{}, -- Title
		},
	})

	local function make_display(entry)
		return displayer({
			{ entry.value, "TelescopeResultsIdentifier" },
			entry.title,
		})
	end

	return function(line)
		local fields = vim.split(line, sep, true)
		return {
			display = make_display,
			filename = fields[1],
			ordinal = fields[1],
			path = opts.memo_dir .. Path.path.sep .. fields[1],
			title = fields[2],
			value = fields[1],
		}
	end
end

local function detect_memo_dir(memo_bin)
	local lines = utils.get_os_command_output({ memo_bin, "config", "--cat" })
	for _, line in ipairs(lines) do
		local dir = line:match('memodir%s*=%s*"(.*)"')
		if dir then
			return vim.fn.expand(dir)
		end
	end
	echo("cannot detect memodir", "ErrorMsg")
end

local function set_default(opts)
	opts = opts or {}
	opts.memo_bin = vim.F.if_nil(opts.memo_bin, "memo")
	opts.memo_dir = utils.get_lazy_default(opts.memo_dir, detect_memo_dir, opts.memo_bin)
	return opts
end

M.make_list = function(memoArgs)
	return function(opts)
		opts = set_default(opts)
		opts.entry_maker = utils.get_lazy_default(opts.entry_maker, gen_from_memo, opts)

		pickers
			.new(opts, {
				prompt_title = "Notes from mattn/memo",
				finder = finders.new_oneshot_job({ "memo", unpack(memoArgs) }, opts),
				sorter = conf.file_sorter(opts),
				previewer = previewers.new_termopen_previewer({
					get_command = function(entry)
						local filepath = from_entry.path(entry)
						if vim.fn.executable("glow") == 1 then
							return { "glow", filepath }
						elseif vim.fn.executable("bat") == 1 then
							return { "bat", "--style", "header,grid", filepath }
						else
							return { "cat", filepath }
						end
					end,
				}),
			})
			:find()
	end
end

M.live_grep = function(opts)
	local memo_opts = set_default(opts)
	opts = vim.tbl_extend("force", { cwd = memo_opts.memo_dir }, opts or {})
	builtin.live_grep(opts)
end

M.grep_string = function(opts)
	local memo_opts = set_default(opts)
	opts = vim.tbl_extend("force", { cwd = memo_opts.memo_dir }, opts or {})
	builtin.grep_string(opts)
end

return M
