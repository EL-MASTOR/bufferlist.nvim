![bufferlist preview](https://i.ibb.co/zbxwrXk/Screenshot-20240920-162143-com-termux.jpg)
## Features
 - Manage buffers (**list, switch, save, delete**)
 - Super lightweight (**all the code is in a single file with less than 200 lines of code**)
 - Super fast, (*since the code base is very small*) 
 - Super easy to use, (**_you can list, switch and manage buffers with as few key strokes as possible_**)
 - buffer unsaved icon
 - Support for diagnostics
 - responsive height

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "EL_MASTOR/bufferlist.nvim",
  lazy = true,
  keys = { { "<Leader>b", desc = "Open bufferlist" } }, -- keymap to load the plugin, it should be the same as keymap.open_buflist
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}
```
### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use {
  "EL_MASTOR/bufferlist.nvim",
  -- add a line for dependencies for devicons
  config = function()
    require("bufferlist").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end
}
```


## ⚙️ Configuration

Bufferlist comes with the following defaults:

```lua
{
  keymap = {
    open_bufferlist = "<leader>b",
    close_buf_prefix = "c",
    force_close_buf_prefix = "f",
    save_buf = "s", 
    close_bufferlist = "q" 
  },
  width = 40
}
```
## Usage
### Open bufferlist
Press `<leader>b` in normal mode

### **_The following key maps are buffer local key maps, they work only inside the bufferlist floating window_**
>❗️📑📒 **_Note:_**_*`<line_number>` and `<prefix>` represent the line number of the buffer name, and the first key in the keymap respectively*_

### Switching to an other buffer
press the `<line_number>` of the buffer name you want to switch to (**very simple, isn't this the easiest**)
> when the loaded buffers are 10 or more, you have to press the numbers quickly to get to the buffer who has 2 digits in `<line_number>`.
> For example, if you have 15 loaded buffers that are displayed in the bufferlist window, and you want to get to the buffer whose `<line_number>` is 12, you need to press 1 and quickly press 2, if you're wait after pressing 1 you will go to the buffer in `<line_number>` 1 instead 

### Saving buffers
If the buffer is not saved, a circle icon is shown before the buffer name, to save it press `s<line_number>`
### Closing buffers
Press `c<line_number>`. (**_doesn't work when the buffer has unsaved changes_**)
### Force closing buffers
Pressing `f<line_number>` will close the buffer even if it contains unsaved changes
### Closing buffer list window
Press `keymap.close_bufferlist` or just leave the bufferlist window

>❗️📑📒 **_Note:_** _[timeout](https://neovim.io/doc/user/options.html#'timeout') between `<perfix>` and `<line_number>` is controlled by the vim global option [timeoutlen](https://neovim.io/doc/user/options.html#'timeoutlen') (*which by default is set to 1000ms*).
>You have to quickly press `<line_number>` before timeoutlen. Otherwise vim will enter operator pending mode and these keymaps will not work.
This happens because there are global defined key maps starting one of with the keys `s`, `c` or `f`. If you wait until timeoutlen has passed, vim will execute the global mapping instead. Therefore you have to press *Esc* and try again quicker.
However it is still recommended to not remap them using `ctrl`, `alt`, `shift` and `<leader>` keys since that will add more key strokes for you._

## Highlight groops

- `BufferListCurrentBuffer`
- `BufferListModifiedIcon`
- `BufferListCloseIcon`
- `BufferListLine`

## Feedback

- If you've got an issue or come up with an awesome idea, don't hesitate to open an issue in github.
- If you think this plugin is useful or cool, consider rewarding it with a star.
