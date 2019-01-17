function! s:StartWith(string, substring)
    if strlen(a:string) < strlen(a:substring)
        return 0
    elseif a:string[0:(strlen(a:substring)-1)] ==# a:substring
        return 1
    else
        return 0
    endif
endfunction


" function! TESTFUNC(channel)
"     " echom("Hello before 2000ms @". strftime('%T'))
"     " sleep 2000ms
"     " echom("Hello after 2000ms @". strftime('%T'))
"     echo ch_read(a:channel)
" endfunction

" function! TESTWRAPPER()
"     " let g:Hello_codes = ['echom 1', 'echom 2', 'if 0', 'echom 3', 'elseif 0', 'echom 4', 'else', 'if 1', 'echom 6', 'endif', 'echom 5', 'endif']
"     " let g:Hello_index = 0
"     " call job_start("echo 'g:Hello'", {'close_cb': 'AsyncFuncRun'})
"     let g:test_loop_codes = ['let g:index = 0', 'LABEL FIRST', 'if g:index < 4', 'echom strftime("%T") . g:index', 'let g:index = g:index + 1', 'sleep 2s', 'GOTO FIRST', 'endif']
"     let g:test_loop_index = 0
"     call job_start("echo 'g:test_loop'", {'close_cb': 'AsyncFuncRun'})
" endfunction

" let g:test = 0

function! AsyncFuncRun(channel)
    " let g:test = g:test + 1
    " echom strftime('%T') . string(a:channel)
    " echom ch_status(a:channel, {'part': 'out'})
    if ch_status(a:channel, {'part': 'out'}) == 'buffered'
        " echom a:channel
        let l:name = ch_read(a:channel)[1:-2]
        " echom l:name
    endif
    if !exists('l:name')
        if exists('g:ASYNCVIM_JOB_FOR_SLEEP')
            let l:name = g:ASYNCVIM_JOB_FOR_SLEEP
            unlet g:ASYNCVIM_JOB_FOR_SLEEP
        else
            return
        endif
    endif
    " let g:test = g:test + 1
    " if g:test > 20
    "     return
    " endif
    let l:codes = eval(l:name . '_codes')
    let l:index = eval(l:name . '_index')
    " echom string(l:codes)
    " echom string(l:index)
    if l:index == len(l:codes)
        return
    endif
    " echom string(a:channel) . ': ' . l:codes[l:index]
    " let g:Hello_index = g:Hello_index + 1
    let l:code = l:codes[l:index]
    if s:StartWith(l:code, 'let ') || s:StartWith(l:code, 'echo') || s:StartWith(l:code, 'execute') || s:StartWith(l:code, 'call')
        execute l:code
        execute 'let '. l:name . '_index = ' . l:index . ' + 1'
    elseif s:StartWith(l:code, 'if')
        if eval(l:code[3:])
            execute 'let '. l:name . '_index = ' . l:index . ' + 1'
        else
            let l:temp = l:index + 1
            let l:level = 0
            while l:temp < len(l:codes)
                if s:StartWith(l:codes[l:temp], 'if ')
                    let l:level = l:level + 1
                elseif s:StartWith(l:codes[l:temp], 'endif')
                    let l:level = l:level - 1
                endif
                if l:level == 0 && l:codes[l:temp] ==# 'else'
                    execute 'let '. l:name . '_index = ' . l:temp . ' + 1'
                    break
                elseif l:level == 0 && s:StartWith(l:codes[l:temp], 'elseif')
                    if eval(l:codes[l:temp][7:])
                        execute 'let '. l:name . '_index = ' . l:temp . ' + 1'
                        break
                    endif
                elseif l:level == -1
                    execute 'let '. l:name . '_index = ' . l:temp . ' + 1'
                    break
                endif
                let l:temp = l:temp + 1
            endwhile
        endif
    elseif l:code ==# 'else'
        let l:temp = l:index + 1
        let l:level = 0
        while l:temp < len(l:codes)
            if s:StartWith(l:codes[l:temp], 'if ')
                let l:level = l:level + 1
            elseif l:codes[l:temp] ==# 'endif'
                let l:level = l:level - 1
            endif
            let l:temp = l:temp + 1
            if l:level == -1
                break
            endif
        endwhile
        execute 'let '. l:name . '_index = ' . l:temp
    elseif l:code ==# 'endif'
        execute 'let '. l:name . '_index = ' . l:index . ' + 1'
    elseif s:StartWith(l:code, 'wait')
        if eval(l:code[5:])
            execute 'let '. l:name . '_index = ' . l:index . ' + 1'
        else
            " echom string(a:channel) . ' JOB_START: ' . l:code
            let g:ASYNCVIM_JOB_FOR_SLEEP = l:name
            call job_start('sleep 0.05s', {'close_cb': 'AsyncFuncRun'})
            return
        endif
    elseif s:StartWith(l:code, 'LABEL ')
        execute 'let '. l:name . '_index = ' . l:index . ' + 1'
    elseif s:StartWith(l:code, 'GOTO ')
        let l:temp = 0
        while l:temp < len(l:codes)
            if s:StartWith(l:codes[l:temp], 'LABEL ') && l:codes[l:temp][6:] ==# l:code[5:]
                execute 'let '. l:name . '_index = ' . l:temp . ' + 1'
                break
            endif
            let l:temp = l:temp + 1
        endwhile
    elseif s:StartWith(l:code, 'sleep ')
        execute 'let '. l:name . '_index = ' . l:index . ' + 1'
        " echom string(a:channel) . ' JOB_START: ' . l:code . "&& echo '" . l:name . "' @ " . strftime('%T')
        " call job_start("sleep 2s & echo 'g:test_loop'", {'close_cb': 'AsyncFuncRun'})
        let g:ASYNCVIM_JOB_FOR_SLEEP = l:name
        call job_start(l:code, {'close_cb': 'AsyncFuncRun'})
        " call job_start(l:code . " && echo '" . l:name . "'", {'close_cb': 'AsyncFuncRun'})
        return
    endif
    " echom "hahah"
    call job_start("echo '". l:name . "'", {'close_cb': 'AsyncFuncRun'})
endfunction
