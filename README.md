# `mdpreview.nvim`

`mdpreview.nvim` is a Neovim plugin to preview Markdown files using CLI Markdown renderers. By default, uses [charmbracelet/glow](https://github.com/charmbracelet/glow).
It can use any CLI that can render Markdown from `STDIN`.

![Demo gif of live updating Markdown preview](https://user-images.githubusercontent.com/8648891/258194101-9e78b245-3f3e-4bb5-a7de-c8cf513832c1.gif)

## Plugin Status

This plugin should be considered alpha software at this time. Breaking changes may land on `master` at any time. Once the plugin is stable I will move to semantic versioning.

## Installation

First ensure you have `glow` (or another Markdown renderer CLI) installed on your system. If it is not in `$PATH`, you can configure an explicit path in the plugin settings.

### With `lazy.nvim`

```lua
{
  'mrjones2014/mdpreview.nvim',
  ft = 'markdown', -- you can lazy load on markdown files only
  -- requires the `terminal` filetype to render ASCII color and format codes
  dependencies = { 'norcalli/nvim-terminal.lua', config = true },
}
```

## Usage

From a Markdown file, run the `:Mdpreview` command to start a live-updating preview in a vertical split, and `:Mdpreview!` to close it.
You can also run `:MdpreviewCurrent` to run the preview in a new buffer in the current window, and `:MdpreviewCurrent!` to close it.
Both previews can also be closed with `q`, or by closing the source buffer.

## Configuration

Default configuration shown below:

```lua
require('mdpreview').setup({
  -- specify manually if `glow` is not on `$PATH` or you want to use another CLI, or use different args
  cli_args = {
    'glow',
    -- glow assumes you want no colors if not run in a TTY
    '-s',
    'dark',
    -- let nvim handle word wrapping, disable glow word wrap
    '-w',
    '1',
    -- don't unexpectedly make network connections
    '--local',
  },
  -- enabled on these filetypes
  filetypes = { 'markdown', 'markdown.pandoc', 'markdown.gfm' },
  renderer = {
    -- use the nvim buffer renderer, currently `buffer` is the only available backend
    backend = 'buffer',
    -- options for the renderer backend
    opts = {
      -- if you don't want to use a vertical split, create your own window
      -- and return the window ID. May be a function or a number if you already
      -- have the window ID
      winnr = function()
        vim.cmd('vsp')
        return vim.api.nvim_get_current_win()
      end,
      -- options that will be set on the preview window
      win_opts = {
        signcolumn = 'no',
        number = false,
        concealcursor = 'niv',
        wrap = true,
        linebreak = true,
      },
    },
  },
})
```

## API

You can override `Config.renderer` by passing it as a table into `preview()` like so:

```lua
require('mdpreview').preview({
  backend = 'buffer',
  opts = {
    winnr = function()
      return some_window_id
    end,
  },
})
```
