let s:code = ['let s:index = 1', 'LABEL tt', 'echo s:index', 'sleep 1000', 'let s:index = s:index + 1', 'if s:index < 4', 'GOTO tt', 'endif']
call async#AsyncFuncRun(s:code, 0, 0, 0)
