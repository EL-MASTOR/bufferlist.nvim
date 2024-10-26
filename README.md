![bufferlist preview](https://i.imgur.com/pgVqpfN.jpeg)
![bufferlist multi-save preview](https://i.imgur.com/5ujoFpe.jpeg)
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
 - Not gluted with unnecessary features. (**_bufferlist comes only with features that you would use_**)

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "EL-MASTOR/bufferlist.nvim",
  lazy = true,
  keys = { { "<Leader>b", ':BufferList<CR>', desc = "Open bufferlist" } },
  dependencies = "nvim-tree/nvim-web-devicons",
  cmd = "BufferList",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}
```
## ⚙️ Configuration

Bufferlist comes with the following defaults:

```lua
{
  keymap = {
    close_buf_prefix = "c",
    force_close_buf_prefix = "f",
    save_buf = "s", 
    multi_close_buf = "m",
    multi_save_buf = "w",
    save_all_unsaved="a",
    close_all_saved="d0",
    close_bufferlist = "q" 
  },
  win_keymaps = {}, -- add keymaps to the BufferList window
  bufs_keymaps = {}, -- add keymaps to each line number in the BufferList window
  width = 40,
  prompt = "", -- for multi_{close,save}_buf prompt
  save_prompt = "󰆓 ",
  top_prompt = true, -- set this to false if you want the prompt to be at the bottom of the window instead of on top of it.
}
```
## Usage
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

### Adding custom BufferList window keymaps
You can assign custom keymaps to the BufferList window with `win_keymaps` option.
`win_keymaps` takes a table of `{key, func, keymap_opts}` items.
- `key`: (string) Left-hand side {lhs} of the mapping.
- `func`: (function) Right-hand side {rhs} of the mapping.
  - Receives one argument, a table with the following keys:
    - `winid`: (number) the window id of the BufferList window.
    - `bl_buf`: (number) the bufferlist window scratch buffer.
    - `buffers`: (table) the listed buffers ids.
    - `open_bufferlist`: (function) function to open the BufferList window. _(useful for refreshing the BufferList window. But you will have to delete the BufferList scratch buffer first. with `bwipeout` for example. As shown in the example below).
- `opts`: (table) Same opts passed to `vim.keymap.set()`. (The `buffer` field is not necessary).

This example shows how to set a custom keymap for switching buffers with the enter key, and a usless one for an unnecessary refresh:
```lua
win_keymaps = {
  {
    "<cr>",
    function(opts)
      local curpos = vim.fn.line(".")
      vim.cmd("bwipeout | buffer " .. opts.buffers[curpos])
    end,
  { desc = "BufferList: my description" },
  },
  {
    "r", -- refresh the bufferlist window
    function(opts)
      vim.cmd('bwipeout')
      opts.open_bufferlist()
    end,
    {}
  }
},
```

>❗️📑📒 **_Note:_** _All of these keymaps are local to the BufferList. Everything will all be removed when you close the BufferList window.

> **_Note:_** _The `<cr>` keymap here serves just as an example. BufferList doesn't ship with it for a reason. It defies one of BufferList's core principles: "As few key strokes as posssible". Most people who want it are just used to interfaces with the same navigation `<cr>`. If you're one yourself, I highly recommended not setting this keymap since it will slow you down. And try getting used to the BufferList's way of doing things instead.

### Adding keymaps for buffers
You can also add keymaps to line numners in the BufferList window with `bufs_keymaps` option.
`bufs_keymaps` takes a table of `{key, func, keymap_opts}` items.
- `key`: (string) Left-hand side {lhs} of the mapping. **Will be suffixed with the `<line_number>s`**.
- `func`: (function) Right-hand side {rhs} of the mapping.
  - Receives one argument, a table with the following keys:
    - `line_number`: (number) `<line_number>` pressed after `key`
    - `bl_buf`: (number) the bufferlist window scratch buffer.
    - `buffers`: (table) the listed buffers ids.
    - `open_bufferlist`: (function) function to open the BufferList window. _(useful for refreshing the BufferList window. But you will have to delete the BufferList scratch buffer first. with `bwipeout` for example. As shown in the example above).
- `opts`: (table) Same opts passed to `vim.keymap.set()`. (The `buffer` field is not necessary). **`desc` option (if specified) will be suffixed with the icon and the buffername in the corresponding line number**.

Here is an example of adding keymaps to show the buffer in a new split window. As well as again some uselessness.
```lua
bufs_keymaps = {
  {
    "vs",
    function(opts)
      vim.cmd("bwipeout | vs " .. vim.fn.bufname(opts.buffers[opts.line_number]))
    end,
    { desc = "BufferList: show buffer in a split window" }, -- desc (if present) will be suffixed with the contents of each of the lines in the BufferList window. for example: "BufferList: show in a split window  example.lua"
  },
  {
    "p",
    function(opts)
      vim.cmd(":echo 'line_number is: " .. tostring(opts.line_number) .. ", bl_buf is: " .. tostring(opts.bl_buf) .. "'")
    end,
    {},
  },
},
```
Now you can press `vs5` to show the buffer at line 5 in a new window. And press `p3` to print a useless message.

>❗️📑📒 **_Note:_** _All of these keymaps are local to the BufferList. Everything will all be removed when you close the BufferList window.

## User commands
`BufferList`

## General notes
>❗️📑📒 **_Note:_** _[timeout](https://neovim.io/doc/user/options.html#'timeout') between `<perfix>` and `<line_number>` is controlled by the vim global option [timeoutlen](https://neovim.io/doc/user/options.html#'timeoutlen') (*which by default is set to 1000ms*).

>❗️You have to quickly press `<line_number>` before timeoutlen. Otherwise vim will enter operator pending mode and these keymaps will not work.
>This happens because there are global defined key maps starting one of with the keys `s`, `c` or `f`. If you wait until timeoutlen has passed, vim will execute the global mapping instead. Therefore you have to press *Esc* and try again quicker.
>However it is still recommended to not remap them using `ctrl`, `alt`, `shift` and `<leader>` keys since that will add more key strokes for you._

>❗️📑📒 **_Note:_** _Terminal buffers are ignored in closing or multi-closing. To close them, you have to [force-close](#force-closing-buffers) them, or [force-multi-close](#force-closing-multiple-buffers) them.

>💡 **_Tip:_** _Does not provide keymappings for commands, or maps already builtin in nvim, (such as `:bnext`, `:bufdo`, `<Ctrl_6>`, ...). If you want additional mappings for buffer management and navigations, you can check out `:h buffer-list`, `:h editing`, `:h windows`, etc... .

>❗️📑📒 **_Note:_** _The buffers are listed in the same order as the buffer-list (`:buffers`).

>❗️📑📒 **_Note:_** _Empty buffers are ignored while saving. (empty buffers usually occur when they are in the `argument-list` but not yet loaded).

>📑📒 **_Note:_** _Bufferlist will show icons in the virt text. If you have diagnostic icons defined (for example with `sign_defign`), bufferlist will show the latter instead.

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
