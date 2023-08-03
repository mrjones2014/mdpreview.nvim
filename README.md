# `glowy.nvim`

`glowy.nvim` is a Neovim plugin to preview Markdown files using [charmbracelet/glow](https://github.com/charmbracelet/glow).

![Demo gif of live updating Markdown preview](https://user-images.githubusercontent.com/8648891/258194101-9e78b245-3f3e-4bb5-a7de-c8cf513832c1.gif)

## Installation

First ensure you have `glow` installed on your system. If it is not in `$PATH`, you can configure an explicit path in the plugin settings.

### With `lazy.nvim`

```lua
{
  'mrjones2014/glowy.nvim',
  ft = 'markdown', -- you can lazy load on markdown files only
  -- requires the `terminal` filetype to render ASCII color and format codes
  dependencies = { 'norcalli/nvim-terminal.lua', config = true },
}
```

## Usage

From a Markdown file, run the `:Glowy` command to start a live-updating preview in a vertical split.

## Configuration

Default configuration shown below:

```lua
require('glowy').setup({
  -- specify manually if `glow` is not on `$PATH`
  glow_path = 'glow',
  -- if you don't want to use a vertical split, create your own window
  -- and return the window ID
  create_preview_win = function()
    vim.cmd('vsp')
    return vim.api.nvim_get_current_win()
  end,
  -- enabled on these filetypes
  filetypes = { 'markdown', 'markdown.pandoc', 'markdown.gfm' },
})
```
