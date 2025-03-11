![bufferlist preview](https://i.imgur.com/QAOBNzH.jpeg)
![bufferlist multi-save preview](https://i.imgur.com/Sv12Wlz.jpeg)

## Table of Contents
- [Features](#features)
- [Installation](#installation)
  - lazy.nvim
- [Requirements](#requirements)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Switching to an other buffer](#switching-to-an-other-buffer)
  - [Saving buffers](#saving-buffers)
  - [Closing buffers](#closing-buffers)
  - [Force closing buffers](#force-closing-buffers)
  - [Saving all unsaved buffers](#saving-all-unsaved-buffers)
  - [Closing all saved buffers](#closing-all-saved-buffers)
  - [Closing multiple buffers](#closing-multiple-buffers)
  - [Force closing multiple buffers](#force-closing-multiple-buffers)
  - [Saving multiple buffers](#saving-multiple-buffers)
  - [Visual mode support](#visual-mode-support)
    - [Visual multi-closing](#visual-multi-closing)
    - [Visual force multi-closing](#visual-force-multi-closing)
    - [Visual multi-saving](#visual-multi-saving)
  - [Toggle or show relative path](#toggle-or-show-relative-path)
    - [Toggle relative path](#toggle-relative-path)
    - [Show relative path](#show-relative-path)
  - [Adding custom keymaps](#adding-custom-keymaps)
    - [For BufferList window](#for-bufferlist-window)
    - [For buffers](#for-buffers)
  - [Closing buffer list window](#closing-buffer-list-window)
  - [User commands](#user-commands)
  - [Health](#health)
  - [General notes](#general-notes)
  - [Highlight groops](#highlight-groops)
  - [Feedback](#feedback)

## Features
 - Manage buffers (**list, switch, save, close, multi-(save,close)**).
 - Super lightweight (**all the code is in a single file**).
 - Super fast, (*since the code base is very small*).
 - Super easy to use, (**_you can list, switch and manage buffers with as few key strokes as possible_**).
 - Highlights the buffer lines as you write them in the prompt.
 - Custom keymaps.
 - Save all unsaved.
 - Close all saved.
 - multi-(close/save)ing.
 - Visual mode support. **(2nd method of multi-(save/close)ing.)**
 - Show or toggle relative path.
 - Buffer unsaved icon.
 - Support for diagnostics.
 - Responsive height.
 - Not gluted with unnecessary features. (**_BufferList comes only with features that you would use._**)

## Installation

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
## Requirements

[nvim-tree/nvim-web-devicons"](https://github.com/nvim-tree/nvim-web-devicons) for filetype icons.

_**(recommended)**_ [realpath](https://www.gnu.org/software/coreutils/manual/html_node/realpath-invocation.html) for better relative paths generating.

## Configuration

Bufferlist comes with the following defaults:

```lua
{
  keymap = {
    close_buf_prefix = "c",
    force_close_buf_prefix = "f",
    save_buf = "s",
    visual_close = "d",
    visual_force_close = "f",
    visual_save = "s",
    multi_close_buf = "m",
    multi_save_buf = "w",
    save_all_unsaved = "a",
    close_all_saved = "d0",
    toggle_path = "p",
    close_bufferlist = "q",
  },
  win_keymaps = {}, -- add keymaps to the BufferList window
  bufs_keymaps = {}, -- add keymaps to each line number in the BufferList window
  width = 40,
  icons = {
    prompt = "", -- for multi_{close,save}_buf prompt
    save_prompt = "󰆓 ",
    line = "▎",
    modified = "󰝥",
  },
  top_prompt = true, -- set this to false if you want the prompt to be at the bottom of the window instead of on top of it.
  show_path = false, -- show the relative paths the first time BufferList window is opened
}
```
## Usage
>❗️*The following key maps are buffer local key maps, they work only inside the bufferlist floating window*.

>❗️📑📒 **_Note:_**_*`<line_number>` represents the line number of the buffer name*_

### Switching to an other buffer
press the `<line_number>` of the buffer name you want to switch to (**very simple, isn't this the easiest**)
> when the loaded buffers are 10 or more, you have to press the numbers quickly to get to the buffer who has 2 digits in `<line_number>`.
> For example, if you have 10 loaded buffers that are displayed in the bufferlist window, and you want to get to the buffer whose `<line_number>` is 10, you need to press 1 and quickly press 0, if you're wait after pressing 1 you will go to the buffer in `<line_number>` 1 instead.
> See [General notes](#general-notes), and `timeoutlen`.

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

>❗️*Make sure that the first character isn't `!`*.

>❗️*If you specified an unsaved buffer, it is ignored*.

>*If a `<line_number>` you specified doesn't exist in the bufferlist window line numbers, it is ignored*.

### Force closing multiple buffers
Press `keymap.multi_close_buf` and then enter `!` at the very beginning of the prompt, and then carry on with the rest of the steps already described in [Closing multiple buffers](#closing-multiple-buffers)

>❗️*Make sure that `!` is the very first character in the prompt, it shouldn't be preceded by anything, otherwise it would behave just like [Closing multiple buffers](#closing-multiple-buffers)*

### Saving multiple buffers
Press `keymap.multi_save_buf` and then enter all the `<line_number>`s of the buffers you want to save seperated by a seperator. The seperator has the same characteristics described in [Closing multiple buffers](#closing-multiple-buffers)

### Visual mode support
You can also (save/close) multiple buffers by just selecting their lines in visual mode. This is convenient in some cases compared to the other method of multi-(close/save)ing described in the above sections.

#### Visual multi-closing
Select the lines of buffers you want to close in visual mode and press `keymap.visual_close`.

> Unsaved buffers are ignored.

#### Visual force multi-closing
To include unsaved buffers in visual multi-closing, you need to press `keymap.visual_force_close` instead.

#### Visual multi-saving
Press `keymap.visual_save` in visual mode to save all the buffers in the selected lines.

### Toggle or show relative path
>❗️*This uses the output captured from [realpath](https://www.gnu.org/software/coreutils/realpath) if it exists*

>❗️*If [realpath](https://www.gnu.org/software/coreutils/realpath) doesn't exist, it uses vim's builtin `expand("#"..buffer..":~:.:h")` to do neovim's best to determine the relative path. Prefer installing [realpath](https://www.gnu.org/software/coreutils/realpath) over this.*

#### Toggle relative path
press `keymap.toggle_path` to toggle the relative path to each buffer from the neovim cwd `:pwd`.

#### Show relative path
set `show_path` to `true` to show the relative path the first time you open the BufferList window after it has been loaded.

### Adding custom keymaps
You can add custom keymaps for BufferList window via `win_keymaps` option, and keymaps for buffers via `bufs_keymaps` option
#### For BufferList window
You can assign custom keymaps to the BufferList window with `win_keymaps` option.
`win_keymaps` takes a table of `{key, func, keymap_opts}` items.
- `key`: (string) Left-hand side {lhs} of the mapping.
- `func`: (function) Right-hand side {rhs} of the mapping.
  - Receives one argument, a table with the following keys:
    - `winid`: (number) the window id of the BufferList window.
    - `bl_buf`: (number) the bufferlist window scratch buffer.
    - `buffers`: (table) the listed buffers ids.
    - `open_bufferlist`: (function) function to open the BufferList window. _(useful for refreshing the BufferList window. But you will have to delete the BufferList scratch buffer first. with `bwipeout` for example. As shown in the example below).
- `opts`: (table) Same opts passed to `vim.keymap.set()`. (The `buffer` field is not necessary). _`desc` option, if not set, will be automatically set to "BufferList: custom user defined keymap". **see the example bellow**_

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
    {} -- `desc` here isn't set. So it will be automatically set to "BufferList: custom user defined keymap"
  }
},
```

>❗️📑📒 **_Note:_** *All of these keymaps are local to the BufferList. They will all be removed when you close the BufferList window*.

> **_Note:_** *Using the `<cr>` keymap is not recommended, because it will slow you down since it uses more key strokes*.

#### For buffers
You can also add keymaps to line numbers in the BufferList window with `bufs_keymaps` option.
`bufs_keymaps` takes a table of `{key, func, keymap_opts}` items.
- `key`: (string) Left-hand side {lhs} of the mapping. **Will be suffixed with the `<line_number>`s**.
- `func`: (function) Right-hand side {rhs} of the mapping.
  - Receives one argument, a table with the following keys:
    - `line_number`: (number) `<line_number>` pressed after `key`
    - `bl_buf`: (number) the bufferlist window scratch buffer.
    - `buffers`: (table) the listed buffers ids.
    - `open_bufferlist`: (function) function to open the BufferList window. _(useful for refreshing the BufferList window. But you will have to delete the BufferList scratch buffer first. with `bwipeout` for example. As shown in the example above).
- `opts`: (table) Same opts passed to `vim.keymap.set()`. (The `buffer` field is not necessary). _`desc` option (if specified) will be suffixed with the icon and the bufname in the corresponding line number. Otherwise it will be "BufferList: custom user defined buffers keymap for", suffixed by the icon and the bufname. **see the examples bellow**_.

Here is an example of adding keymaps to show the buffer in a new split window. As well as again some uselessness.
```lua
bufs_keymaps = {
  {
    "vs",
    function(opts)
      vim.cmd("bwipeout | vs " .. vim.fn.bufname(opts.buffers[opts.line_number]))
    end,
    { desc = "BufferList: show buffer in a split window" }, -- `desc` (if present) will be suffixed with the contents of each line in the BufferList window. for example, this `desc` will be set to: "BufferList: show buffer in a split window  example.lua".
  },
  {
    "h",
    function(opts)
      vim.cmd(":echo 'line_number is: " .. tostring(opts.line_number) .. ", bl_buf is: " .. tostring(opts.bl_buf) .. "'")
    end,
    {}, -- `desc` option is not present here, so it will automatically be set to a pre-set description with the contents of each line in the BufferList window. for example: "BufferList: custom user defined buffers keymap for  example.lua"
  },
},
```
Now you can press `vs5` to show the buffer at line 5 in a new vertical split window. And press `h3` to print a useless message.

>❗️📑📒 **_Note:_** *All of these keymaps are local to the BufferList. Everything will all be removed when you close the BufferList window*.

### Closing buffer list window
Press `keymap.close_bufferlist`

## User commands
`BufferList`

## Health
`:checkhealth bufferlist`

## General notes
>❗️📑📒 **_Note:_** *[timeout](https://neovim.io/doc/user/options.html#'timeout') between the keymap and `<line_number>` is controlled by the vim global option [timeoutlen](https://neovim.io/doc/user/options.html#'timeoutlen')* (*which by default is set to 1000ms*).

>❗️*You have to quickly press `<line_number>` before timeoutlen. Otherwise vim will enter operator pending mode and these keymaps will not work*.
>*This happens because there are global defined key maps starting one of with the keys `s`, `c` or `f`. If you wait until timeoutlen has passed, vim will execute the global mapping instead. Therefore you have to press `Esc` and try again quicker.
>However it is still recommended to not remap them using `ctrl`, `alt`, `shift` and `<leader>` keys since that will add more key strokes for you*.

>❗️📑📒 **_Note:_** *Terminal buffers are ignored in closing or multi-closing. To close them, you have to [force-close](#force-closing-buffers) them, or [force-multi-close](#force-closing-multiple-buffers) them*.

>💡 **_Tip:_** *Does not provide keymappings for commands, or maps already builtin in nvim, (such as `:bnext`, `:bufdo`, `<Ctrl_6>`, ...). If you want additional mappings for buffer management and navigations, you can check out `:h buffer-list`, `:h editing`, `:h windows`, etc*... .

>❗️📑📒 **_Note:_** *The buffers are listed in the same order as the buffer-list (`:buffers`)*.

>❗️📑📒 **_Note:_** *Empty buffers are ignored while saving. (empty buffers usually occur when they are in the `argument-list` but not yet loaded)*.

>📑📒 **_Note:_** *Bufferlist will show icons in the virt text. If you have diagnostic icons defined (for example with `sign_defign`), bufferlist will show the latter instead*.

## Highlight groops

- `BufferListCurrentBuffer`
- `BufferListModifiedIcon`
- `BufferListLine`
- `BufferListPromptSeperator`
- `BufferListPromptForce`
- `BufferListPromptMultiSelected`
- `BufferListPath`

## Feedback

- If you've got an issue or come up with an awesome idea, please don't hesitate to open an issue on github. I appreciate every suggestion.
- If you think this plugin is useful or cool, consider rewarding it with a ⭐.
