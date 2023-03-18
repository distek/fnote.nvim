Fnote = {}

Fnote.bufid = nil
Fnote.winid = nil

Fnote.config = {
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
	local a = Fnote.config.anchor

	local vimW = vim.o.columns
	local vimH = vim.o.lines

	if a == "NW" then
		return Fnote.config.window.offset.x, Fnote.config.window.offset.y
	elseif a == "W" then
		return Fnote.config.window.offset.x, (vimH / 2) - (height / 2) - 1
	elseif a == "SW" then
		return Fnote.config.window.offset.x, vimH - height - Fnote.config.window.offset.y - 2
	elseif a == "N" then
		return (vimW / 2) - (width / 2) - 1, Fnote.config.window.offset.y
	elseif a == "center" then
		return (vimW / 2) - (width / 2) - 1, (vimH / 2) - (height / 2) - 1
	elseif a == "S" then
		return (vimW / 2) - (width / 2) - 1, vimH - height - Fnote.config.window.offset.y - 2
	elseif a == "NE" then
		return vimW - width - Fnote.config.window.offset.x - 2, Fnote.config.window.offset.y
	elseif a == "E" then
		return vimW - width - Fnote.config.window.offset.x - 2, (vimH / 2) - (height / 2) - 1
	elseif a == "SE" then
		return vimW - width - Fnote.config.window.offset.x - 2, vimH - height - Fnote.config.window.offset.y - 3
	end
end

local function float()
	vim.cmd("split")

	local curWin = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(curWin, Fnote.bufid)

	local width, height

	if Fnote.config.window.percent then
		width = math.floor((Fnote.config.window.width * 0.01) * vim.o.columns)
		height = math.floor((Fnote.config.window.height * 0.01) * vim.o.lines)
	end

	local x, y = getPos(width, height)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = x,
		row = y,
		style = "",
		border = Fnote.config.window.border or "single",
	}

	vim.api.nvim_win_set_option(curWin, "winhighlight", "Normal:FNoteWindow")

	vim.api.nvim_win_set_config(curWin, opts)

	return curWin
end

function Fnote.new()
	local buf = vim.fn.bufadd(Fnote.config.notes_file)

	vim.bo[buf].buflisted = false
	vim.bo[buf].bufhidden = "hide"

	Fnote.bufid = buf
end

function Fnote.open()
	if Fnote.bufid == nil then
		Fnote.new()
	end

	Fnote.winid = float()
end

function Fnote.close()
	if Fnote.winid == nil then
		return
	end

	if not vim.api.nvim_win_is_valid(Fnote.winid) then
		Fnote.winid = nil
		return
	end

	vim.api.nvim_win_close(Fnote.winid, true)

	Fnote.winid = nil
end

function Fnote.toggle()
	if Fnote.winid == nil then
		Fnote.open()
		return
	end

	if not vim.api.nvim_win_is_valid(Fnote.winid) then
		Fnote.open()
		return
	end

	Fnote.close()
end

function Fnote.setup(config)
	Fnote.config = vim.deepcopy(defaultConfig)

	if config then
		Fnote.config = vim.tbl_deep_extend("keep", config, Fnote.config)
	end
end

return Fnote
