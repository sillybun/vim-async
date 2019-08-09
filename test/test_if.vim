let s:code = ['if 1', 'echo 1', 'else', 'echo 2', 'endif', 'if 0', 'echo 3', 'else', 'echo 4', 'endif', 'echo "end"']
call async#AsyncRun(s:code, 0, 0, 0)
let s:code = ['if 0', 'echo 1', 'elseif 0', 'echo 2', 'elseif 1', 'echo 3', 'else', 'echo 4', 'endif', 'echo "end"']
call async#AsyncRun(s:code, 0, 0, 0)
let s:code = ['if 0', 'echo 1', 'elseif 0', 'echo 2', 'elseif 0', 'echo 3', 'else', 'echo 4', 'endif', 'echo "end"']
call async#AsyncRun(s:code, 0, 0, 0)
