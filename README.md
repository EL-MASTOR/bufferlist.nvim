![bufferlist preview](https://i.ibb.co/zbxwrXk/Screenshot-20240920-162143-com-termux.jpg)
![bufferlist multi-save preview](https://imgur.com/a/XPclnC3)
## Features
 - Manage buffers (**list, switch, save, close, multi-(save,close)**)
 - Super lightweight (**all the code is in a single file**)
 - Super fast, (*since the code base is very small*) 
 - Super easy to use, (**_you can list, switch and manage buffers with as few key strokes as possible_**)
 - Highlights the buffer lines as you write them in the prompt
 - Save all unsaved
 - Close all saved
 - Buffer unsaved icon
 - Support for diagnostics
 - Responsive height
 - Not gluted with unessery features. (**_bufferlist comes only with features that you would use_**)

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "EL-MASTOR/bufferlist.nvim",
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
  "EL-MASTOR/bufferlist.nvim",
  -- add a line for dependencies for devicons
  requires = {"nvim-tree/nvim-web-devicons"}
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
    multi_close_buf = "m",
    multi_save_buf = "w",
    save_all_unsaved="a",
    close_all_saved="d0",
    close_bufferlist = "q" 
  },
  width = 40,
  prompt = "", -- for multi_{close,save}_buf prompt
  save_prompt = "󰆓 ",
  top_prompt = true, -- set this to false if you want the prompt to be at the bottom of the window instead of on top of it.
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
### Saving all unsaved buffers
Press `keymap.save_all_unsaved`
### Closing all saved buffers
Press `keymap.close_all_saved`
### Closing multiple buffers
Press `keymap.multi_close_buf` to show a prompt, and then enter the `<line_number>`s of all the buffers you want to close, seperated by a seperator. The seperator should be any non-digit character, and there is no limit to the length or the kind of characters used in the seperator as long as they are not digits.

>❗️Make sure that the first character isn't `!`.

>❗️If you specified an unsaved buffer, it is ignored.

>If a `<line_number>` you specified doesn't exist in the bufferlist window line numbers, it is ignored.

### Force closing multiple buffers
Press `keymap.multi_close_buf` and then enter `!` at the very beginning of the prompt, and then carry on with the rest of the steps already described in [Closing multiple buffers](#closing-multiple-buffers)
    
>❗️Make sure that `!` is the very first character in the prompt, it shouldn't be preceded by anything, otherwise it would behave just like [Closing multiple buffers](#closing-multiple-buffers)

### Saving multiple buffers
Press `keymap.multi_save_buf` and then enter all the `<line_number>`s of the buffers you want to save seperated by a seperator. The seperator has the same characteristics described in [Closing multiple buffers](#closing-multiple-buffers)

### Closing buffer list window
Press `keymap.close_bufferlist` or just leave the bufferlist window

>❗️📑📒 **_Note:_** _[timeout](https://neovim.io/doc/user/options.html#'timeout') between `<perfix>` and `<line_number>` is controlled by the vim global option [timeoutlen](https://neovim.io/doc/user/options.html#'timeoutlen') (*which by default is set to 1000ms*).

>❗️You have to quickly press `<line_number>` before timeoutlen. Otherwise vim will enter operator pending mode and these keymaps will not work.

This happens because there are global defined key maps starting one of with the keys `s`, `c` or `f`. If you wait until timeoutlen has passed, vim will execute the global mapping instead. Therefore you have to press *Esc* and try again quicker.
However it is still recommended to not remap them using `ctrl`, `alt`, `shift` and `<leader>` keys since that will add more key strokes for you._

>❗️📑📒 **_Note:_** _Terminal buffers are ignored in closing or multi-closing. To close them, you have to [force-close](#force-closing-buffers) them, or [force-multi-close](#force-closing-multiple-buffers) them

>💡 **_Tip:_** _If you want additional mappings, you can checkout `:h buffer-list` for available vim commands for buffer management

> You can also press `Ctrl_6` to go to the alternate buffer. This is already included in neovim so make sure to checkout the vim help for available cool buffer tricks, so you don't have to set it up if it's already there.

>❗️📑📒 **_Note:_** _The buffers are listed in the same order as the buffer-list (`:buffers`)

## Highlight groops

- `BufferListCurrentBuffer`
- `BufferListModifiedIcon`
- `BufferListCloseIcon`
- `BufferListLine`
- `BufferListPromptSeperator`
- `BufferListPromptForce`
- `BufferListPromptMultiSelected`

## Feedback

- If you've got an issue or come up with an awesome idea, don't hesitate to open an issue in github.
- If you think this plugin is useful or cool, consider rewarding it with a star.
