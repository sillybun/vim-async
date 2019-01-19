# vim-async

## Introduction

This plugin provide API to run vim function asynchronously.

## Usage

The code need to be executed should be puted into list. For example:

```
let to_be_executed = ['let g:a = 1', 'let g:b = g:a + 1', 'if g:b == 2', 'echo "hello world"', 'endif']
```

And then start the asynchronous job by:

```
AsyncCodeRun(to_be_executed, 'code_name')
```
