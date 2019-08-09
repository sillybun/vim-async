if !exists('g:has_async_engine')
    let g:has_async_engine = 1
endif

" function! TESTWRAPPER()
"     " let g:Hello_codes = ['echom 1', 'echom 2', 'if 0', 'echom 3', 'elseif 0', 'echom 4', 'else', 'if 1', 'echom 6', 'endif', 'echom 5', 'endif']
"     " let g:Hello_index = 0
"     " call job_start("echo 'g:Hello'", {'close_cb': 'AsyncFuncRun'})
"     let g:test_loop_codes = ['let g:index = 0', 'LABEL FIRST', 'if g:index < 4', 'echom strftime("%T") . g:index', 'let g:index = g:index + 1', 'sleep 2000ms', 'GOTO FIRST', 'endif']
"     let g:test_loop_index = 0
"     call AsyncCodeRun(g:test_loop_codes, 'test_loop')
" endfunction

" function! AsyncCodeRun(code, name)
"     let l:name = substitute(a:name, ' ', '', 'g')
"     execute 'let g:' . l:name . '_codes = a:code'
"     execute 'let g:' . l:name . '_index = 0'
"     execute 'let g:' . l:name . '_wait_time = 0'
"     call job_start("echo 'g:" . l:name . "'", {'close_cb': 'async#AsyncFuncRun'})
" endfunction

function! AsyncCodeRun(...)
    call async#AsyncRunEngine(a:1, 0, 0, 0)
endfunction
