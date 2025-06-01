# fnote


> [!WARNING]
> I no longer use this as I've created an alternative solution [using tmux](https://github.com/distek/tmux-tools?tab=readme-ov-file#notes) instead of nvim
> 
> This repo will not be maintained.


Super simple, toggle-able, project notes floating window

## Installation

- Lazy:

```lua
{
    'distek/fnote.nvim',
    config = function()
        require('fnote').setup()
    end
},
```

- Packer:

```lua
use {
    'distek/fnote.nvim',
    config = function()
        require('fnote').setup()
    end
}
```

- Plug:

```vim
Plug 'distek/aftermath.nvim'
```

## Configuration

Default configuration:

```lua
{
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
```

During setup:

```lua
{
    'distek/fnote.nvim',
    config = function()
        require('fnote').setup({
            anchor = "E",
            window = {
                offset = {
                    x = 3,
                    y = 4,
                },
            }
        })
    end
},
```

## Exposed functions

```lua
-- Open the window
require('fnote').open()

-- Close the window
require('fnote').close()

-- Toggle the window
require('fnote').toggle()
```

## Highlight group

Customize `FNoteWindow` if desired
