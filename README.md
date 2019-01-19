# vim-async

## Introduction

This plugin provide API to run vim function asynchronously.

## Usage

The code need to be executed should be put into list. For example:

```
let to_be_executed = ['let g:a = 1', 'let g:b = g:a + 1', 'if g:b == 2', 'echo "hello world"', 'endif']
```

And then start the asynchronous job by:

```
AsyncCodeRun(to_be_executed, 'code_name')
```

## Install

Use your plugin manager of choice.

- [vim-plug](https://github.com/junegunn/vim-plug)
  - Add `Plug 'sillybun/vim-async', {'do': './install.sh'}` to .vimrc
  - Add `Plug 'sillybun/zytutil'` to .vimrc
  - Run `:PlugInstall`

- [Vundle](https://github.com/gmarik/vundle)
  - Add `Bundle 'https://github.com/sillybun/vim-async'` to .vimrc
  - Add `Bundle 'sillybun/zytutil'` to .vimrc
  - Run `:BundleInstall`
  - And change to the plugin directory and run in shell `./install.sh`
