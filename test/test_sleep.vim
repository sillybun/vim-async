let s:code = ['echo 1', 'sleep 100', 'echo 2', 'sleep 100', 'echo 3', 'sleep 100', 'echo 4']
call async#AsyncRun(s:code, 0, 0, 0)
