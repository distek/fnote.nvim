local M = {
	bufid = nil,
	winid = nil,

	config = {
		anchor = nil,
		window = {
			width = nil,
			height = nil,
			percent = nil,
			offset = {
				x = nil,
				y = nil,
			},
			border = nil,
		},
		notes_file = nil,
	},
}

local defaultConfig = {
	anchor = "NE", -- NW, SW, NE, SE, or center
	window = { -- width/height of the window (can be percent)
		width = 40,
		height = 40,
		percent = true, -- interpret width/height as percent instead of fixed values
		offset = { -- Position offset from anchor
			x = 0,
			y = 0,
		},
		border = "single", -- border, see :h nvim_win_set_config
	},
	notes_file = "notes.md", -- project local notes file to use
}

local function getPos(width, height)
	local a = M.config.anchor

	local vimW = vim.o.columns
	local vimH = vim.o.lines

	if a == "NW" then
		return M.config.window.offset.x, M.config.window.offset.y
	elseif a == "W" then
		return M.config.window.offset.x, (vimH / 2) - (height / 2) - 1
	elseif a == "SW" then
		return M.config.window.offset.x, vimH - height - M.config.window.offset.y - 2
	elseif a == "N" then
		return (vimW / 2) - (width / 2) - 1, M.config.window.offset.y
	elseif a == "center" then
		return (vimW / 2) - (width / 2) - 1, (vimH / 2) - (height / 2) - 1
	elseif a == "S" then
		return (vimW / 2) - (width / 2) - 1, vimH - height - M.config.window.offset.y - 2
	elseif a == "NE" then
		return vimW - width - M.config.window.offset.x - 2, M.config.window.offset.y
	elseif a == "E" then
		return vimW - width - M.config.window.offset.x - 2, (vimH / 2) - (height / 2) - 1
	elseif a == "SE" then
		return vimW - width - M.config.window.offset.x - 2, vimH - height - M.config.window.offset.y - 3
	end
end

local function float()
	vim.cmd("split")

	local curWin = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(curWin, M.bufid)

	local width, height

	if M.config.window.percent then
		width = math.floor((M.config.window.width * 0.01) * vim.o.columns)
		height = math.floor((M.config.window.height * 0.01) * vim.o.lines)
	end

	local x, y = getPos(width, height)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = x,
		row = y,
		style = "",
		border = M.config.window.border or "single",
	}

	vim.api.nvim_set_option_value(
		"winhighlight",
		"Normal:FNoteNormal,EndOfBuffer:FNoteEndOfBuffer,NormalNC:FNoteNormalNC,CursorLine:FNoteCursorLine",
		{ win = curWin }
	)

	vim.api.nvim_win_set_config(curWin, opts)

	return curWin
end

function M.new()
	local buf = vim.fn.bufadd(M.config.notes_file)

	vim.bo[buf].buflisted = false
	vim.bo[buf].bufhidden = "hide"
	vim.bo[buf].filetype = "notes.markdown"

	M.bufid = buf
end

function M.open()
	if M.bufid == nil then
		M.new()
	end

	M.winid = float()
end

function M.close()
	if M.winid == nil then
		return
	end

	if not vim.api.nvim_win_is_valid(M.winid) then
		M.winid = nil
		return
	end

	vim.api.nvim_win_close(M.winid, true)

	M.winid = nil
end

function M.toggle()
	if M.winid == nil then
		M.open()
		return
	end

	if not vim.api.nvim_win_is_valid(M.winid) then
		M.open()
		return
	end

	M.close()
end

function M.setup(config)
	M.config = vim.deepcopy(defaultConfig)

	if config then
		M.config = vim.tbl_deep_extend("keep", config, M.config)
	end
end

return M
