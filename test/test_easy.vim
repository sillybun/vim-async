let s:code = ['echo 1', 'echo 2', 'echo 3', 'echo 4']
call async#AsyncRun(s:code, 0, 0, 0)
