let s:VaildCommand = ['let ', 'echo ', 'echom ', 'execute ', 'call ', 'unlet ', 'map', 'umap', 'imap', 'nmap', 'vmap', 'inoremap ', 'nnoremap ', 'vnoremap ', 'autocmd ', 'Plug ', 'au ', 'set ', 'filetype ', 'syntax ']

let s:filename=expand('<sfile>:p:h')

function! async#AsyncFuncRun(channel) abort
    " let g:test = g:test + 1
    " echom strftime('%T') . string(a:channel)
    " echom ch_status(a:channel, {'part': 'out'})
    if ch_status(a:channel, {'part': 'out'}) ==# 'buffered'
        " echom a:channel
        let l:name = ch_read(a:channel)[1:-2]
        " echom l:name
        " echom ch_read(a:channel)
    endif
    if !exists('l:name')
        " if exists('g:ASYNCVIM_JOB_FOR_SLEEP')
        "     let l:name = g:ASYNCVIM_JOB_FOR_SLEEP
        "     unlet g:ASYNCVIM_JOB_FOR_SLEEP
        " else
        return
        " endif
    endif
    " let g:test = g:test + 1
    " if g:test > 30
    "     return
    " endif
    let l:codes = eval(l:name . '_codes')
    let l:index = eval(l:name . '_index')
    let l:wait_time = eval(l:name . '_wait_time')
    " echom string(l:index)
    if l:index == len(l:codes)
        return
    endif
    " echom string(a:channel) . ': ' . l:codes[l:index]
    " let g:Hello_index = g:Hello_index + 1
    let l:code = l:codes[l:index]

    if zyt#str#match#StartWithAnyone(l:code, s:VaildCommand)
        " echom l:code
        " echom 'JOB_START: ' . l:code . "' @ " . strftime('%T')
        " if zyt#str#match#StartWith(l:code, 'call')
        "     echom 'Send Code: ' . g:tasks[g:taskprocess]
        " endif
        execute l:code
        execute 'let '. l:name . '_index = ' . l:index . ' + 1'
    elseif zyt#str#match#StartWith(l:code, 'if')
        if eval(l:code[3:])
            execute 'let '. l:name . '_index = ' . l:index . ' + 1'
        else
            let l:temp = l:index + 1
            let l:level = 0
            while l:temp < len(l:codes)
                if zyt#str#match#StartWith(l:codes[l:temp], 'if ')
                    let l:level = l:level + 1
                elseif zyt#str#match#StartWith(l:codes[l:temp], 'endif')
                    let l:level = l:level - 1
                endif
                if l:level == 0 && l:codes[l:temp] ==# 'else'
                    execute 'let '. l:name . '_index = ' . l:temp . ' + 1'
                    break
                elseif l:level == 0 && zyt#str#match#StartWith(l:codes[l:temp], 'elseif')
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
            if zyt#str#match#StartWith(l:codes[l:temp], 'if ')
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
    elseif zyt#str#match#StartWith(l:code, 'wait')
        if eval(l:code[5:])
            execute 'let '. l:name . '_index = ' . l:index . ' + 1'
            execute 'let '. l:name . '_wait_time = 0'
        else
            " echom string(a:channel) . ' JOB_START: ' . l:code
            " let g:ASYNCVIM_JOB_FOR_SLEEP = l:name
            " echom 'wait for :' . l:code[5:] . ' @ ' . strftime("%T")
            let l:sleep_time = 0.05 + 0.01 * l:wait_time
            " echom 'sleep for' . string(l:sleep_time) . 's'
            execute 'let '. l:name . '_wait_time = ' . l:wait_time . ' + 1'
            call job_start(s:filename . '/sleep ' . string(l:sleep_time) . 's "' . l:name . '"', {'close_cb': 'async#AsyncFuncRun'})
            return
        endif
    elseif zyt#str#match#StartWith(l:code, 'LABEL ')
        execute 'let '. l:name . '_index = ' . l:index . ' + 1'
    elseif zyt#str#match#StartWith(l:code, 'GOTO ')
        let l:temp = 0
        while l:temp < len(l:codes)
            if zyt#str#match#StartWith(l:codes[l:temp], 'LABEL ') && l:codes[l:temp][6:] ==# l:code[5:]
                execute 'let '. l:name . '_index = ' . l:temp . ' + 1'
                break
            endif
            let l:temp = l:temp + 1
        endwhile
    elseif zyt#str#match#StartWith(l:code, 'sleep ')
        execute 'let '. l:name . '_index = ' . l:index . ' + 1'
        " echom string(a:channel) . ' JOB_START: ' . l:code . "&& echo '" . l:name . "' @ " . strftime('%T')
        " call job_start("sleep 2s & echo 'g:test_loop'", {'close_cb': 'AsyncFuncRun'})
        " let g:ASYNCVIM_JOB_FOR_SLEEP = l:name
        " echom s:filename
        call job_start(s:filename . '/sleep ' . l:code[6:] . ' "' . l:name . '"', {'close_cb': 'async#AsyncFuncRun'})
        " call job_start(l:code . " && echo '" . l:name . "'", {'close_cb': 'AsyncFuncRun'})
        return
    elseif zyt#str#match#StartWith(l:code, 'return')
        " echom 'excution finishs @ ' . strftime('%T')
        return
    endif
    call job_start("echo '". l:name . "'", {'close_cb': 'async#AsyncFuncRun'})
endfunction
