let s:VaildCommand = ['let ', 'echo ', 'echom ', 'execute ', 'call ', 'unlet ', 'map', 'umap', 'imap', 'nmap', 'vmap', 'inoremap ', 'nnoremap ', 'vnoremap ', 'autocmd ', 'Plug ', 'au ', 'set ', 'filetype ', 'syntax ']

let s:filename=expand('<sfile>:p:h')

function! async#StartWith(string, substring)
    if strlen(a:string) < strlen(a:substring)
        return 0
    elseif a:string[0:(strlen(a:substring)-1)] ==# a:substring
        return 1
    else
        return 0
    endif
endfunction

function! async#StartWithAnyone(string, list)
    for l:l in a:list
        if async#StartWith(a:string, l:l)
            return 1
        endif
    endfor
    return 0
endfunction

function! async#AsyncRunEngine(codelist, currentline, wait_time, channel) abort
    let l:index = a:currentline
    let l:wait_time = a:wait_time
    while l:index != len(a:codelist)
        let l:currentcode = a:codelist[l:index]
        if async#StartWithAnyone(l:currentcode, s:VaildCommand)
            execute l:currentcode
            let l:index = l:index + 1
            continue
        elseif async#StartWith(l:currentcode, 'if ')
            if eval(l:currentcode[3:])
                let l:index = l:index + 1
                continue
            else
                let l:temp = l:index + 1
                let l:level = 0
                while l:temp < len(a:codelist)
                    if async#StartWith(a:codelist[l:temp], 'if ')
                        let l:level = l:level + 1
                    elseif async#StartWith(a:codelist[l:temp], 'endif')
                        let l:level = l:level - 1
                    endif
                    if l:level == 0 && a:codelist[l:temp] ==# 'else'
                        let l:index = l:temp + 1
                        break
                    elseif l:level == 0 && async#StartWith(a:codelist[l:temp], 'elseif')
                        if eval(a:codelist[l:temp][7:])
                            let l:index = l:temp + 1
                            break
                        endif
                    elseif l:level == -1
                        let l:index = l:temp + 1
                        break
                    endif
                    let l:temp = l:temp + 1
                endwhile
            endif
        elseif l:currentcode ==# 'else'
            let l:temp = l:index + 1
            let l:level = 0
            while l:temp < len(a:codelist)
                if async#StartWith(a:codelist[l:temp], 'if ')
                    let l:level = l:level + 1
                elseif a:codelist[l:temp] ==# 'endif'
                    let l:level = l:level - 1
                endif
                let l:temp = l:temp + 1
                if l:level == -1
                    break
                endif
            endwhile
            let l:index = l:temp
        elseif l:currentcode ==# 'endif'
            let l:index = l:index + 1
        elseif async#StartWith(l:currentcode, 'wait')
            if eval(l:currentcode[5:])
                let l:index = l:index + 1
                let l:wait_time = 0
            else
                let l:sleep_time = 50 + 10 * l:wait_time
                let l:wait_time = l:wait_time + 1
                call timer_start(l:sleep_time, function('async#AsyncRunEngine', [a:codelist, l:index, l:wait_time]))
                return
            endif
        elseif async#StartWith(l:currentcode, 'LABEL ')
            let l:index = l:index + 1
        elseif async#StartWith(l:currentcode, 'GOTO ')
            let l:temp = 0
            while l:temp < len(a:codelist)
                if async#StartWith(a:codelist[l:temp], 'LABEL ') && a:codelist[l:temp][6:] ==# l:currentcode[5:]
                    let l:index = l:temp + 1
                    break
                endif
                let l:temp = l:temp + 1
            endwhile
        elseif async#StartWith(l:currentcode, 'sleep ')
            call timer_start(str2nr(l:currentcode[6:]), function('async#AsyncRunEngine', [a:codelist, l:index+1, 0]))
            return
        elseif async#StartWith(l:currentcode, 'return')
            return
        endif
    endwhile
endfunction

" function! async#AsyncFuncRun(channel) abort
"     " let g:test = g:test + 1
"     " echom strftime('%T') . string(a:channel)
"     " echom ch_status(a:channel, {'part': 'out'})
"     if ch_status(a:channel, {'part': 'out'}) ==# 'buffered'
"         " echom a:channel
"         let l:name = ch_read(a:channel)[1:-2]
"         " echom l:name
"         " echom ch_read(a:channel)
"     endif
"     if !exists('l:name')
"         " if exists('g:ASYNCVIM_JOB_FOR_SLEEP')
"         "     let l:name = g:ASYNCVIM_JOB_FOR_SLEEP
"         "     unlet g:ASYNCVIM_JOB_FOR_SLEEP
"         " else
"         return
"         " endif
"     endif
"     " let g:test = g:test + 1
"     " if g:test > 30
"     "     return
"     " endif
"     let l:codes = eval(l:name . '_codes')
"     let l:index = eval(l:name . '_index')
"     let l:wait_time = eval(l:name . '_wait_time')
"     " echom string(l:index)
"     if l:index == len(l:codes)
"         return
"     endif
"     " echom string(a:channel) . ': ' . l:codes[l:index]
"     " let g:Hello_index = g:Hello_index + 1
"     let l:code = l:codes[l:index]

"     if async#StartWithAnyone(l:code, s:VaildCommand)
"         " echom l:code
"         " echom 'JOB_START: ' . l:code . "' @ " . strftime('%T')
"         " if async#StartWith(l:code, 'call')
"         "     echom 'Send Code: ' . g:tasks[g:taskprocess]
"         " endif
"         execute l:code
"         execute 'let '. l:name . '_index = ' . l:index . ' + 1'
"     elseif async#StartWith(l:code, 'if')
"         if eval(l:code[3:])
"             execute 'let '. l:name . '_index = ' . l:index . ' + 1'
"         else
"             let l:temp = l:index + 1
"             let l:level = 0
"             while l:temp < len(l:codes)
"                 if async#StartWith(l:codes[l:temp], 'if ')
"                     let l:level = l:level + 1
"                 elseif async#StartWith(l:codes[l:temp], 'endif')
"                     let l:level = l:level - 1
"                 endif
"                 if l:level == 0 && l:codes[l:temp] ==# 'else'
"                     execute 'let '. l:name . '_index = ' . l:temp . ' + 1'
"                     break
"                 elseif l:level == 0 && async#StartWith(l:codes[l:temp], 'elseif')
"                     if eval(l:codes[l:temp][7:])
"                         execute 'let '. l:name . '_index = ' . l:temp . ' + 1'
"                         break
"                     endif
"                 elseif l:level == -1
"                     execute 'let '. l:name . '_index = ' . l:temp . ' + 1'
"                     break
"                 endif
"                 let l:temp = l:temp + 1
"             endwhile
"         endif
"     elseif l:code ==# 'else'
"         let l:temp = l:index + 1
"         let l:level = 0
"         while l:temp < len(l:codes)
"             if async#StartWith(l:codes[l:temp], 'if ')
"                 let l:level = l:level + 1
"             elseif l:codes[l:temp] ==# 'endif'
"                 let l:level = l:level - 1
"             endif
"             let l:temp = l:temp + 1
"             if l:level == -1
"                 break
"             endif
"         endwhile
"         execute 'let '. l:name . '_index = ' . l:temp
"     elseif l:code ==# 'endif'
"         execute 'let '. l:name . '_index = ' . l:index . ' + 1'
"     elseif async#StartWith(l:code, 'wait')
"         if eval(l:code[5:])
"             execute 'let '. l:name . '_index = ' . l:index . ' + 1'
"             execute 'let '. l:name . '_wait_time = 0'
"         else
"             " echom string(a:channel) . ' JOB_START: ' . l:code
"             " let g:ASYNCVIM_JOB_FOR_SLEEP = l:name
"             " echom 'wait for :' . l:code[5:] . ' @ ' . strftime("%T")
"             let l:sleep_time = 0.05 + 0.01 * l:wait_time
"             " echom 'sleep for' . string(l:sleep_time) . 's'
"             execute 'let '. l:name . '_wait_time = ' . l:wait_time . ' + 1'
"             call job_start(s:filename . '/sleep ' . string(l:sleep_time) . 's "' . l:name . '"', {'close_cb': 'async#AsyncFuncRun'})
"             return
"         endif
"     elseif async#StartWith(l:code, 'LABEL ')
"         execute 'let '. l:name . '_index = ' . l:index . ' + 1'
"     elseif async#StartWith(l:code, 'GOTO ')
"         let l:temp = 0
"         while l:temp < len(l:codes)
"             if async#StartWith(l:codes[l:temp], 'LABEL ') && l:codes[l:temp][6:] ==# l:code[5:]
"                 execute 'let '. l:name . '_index = ' . l:temp . ' + 1'
"                 break
"             endif
"             let l:temp = l:temp + 1
"         endwhile
"     elseif async#StartWith(l:code, 'sleep ')
"         execute 'let '. l:name . '_index = ' . l:index . ' + 1'
"         " echom string(a:channel) . ' JOB_START: ' . l:code . "&& echo '" . l:name . "' @ " . strftime('%T')
"         " call job_start("sleep 2s & echo 'g:test_loop'", {'close_cb': 'AsyncFuncRun'})
"         " let g:ASYNCVIM_JOB_FOR_SLEEP = l:name
"         " echom s:filename
"         call job_start(s:filename . '/sleep ' . l:code[6:] . ' "' . l:name . '"', {'close_cb': 'async#AsyncFuncRun'})
"         " call job_start(l:code . " && echo '" . l:name . "'", {'close_cb': 'AsyncFuncRun'})
"         return
"     elseif async#StartWith(l:code, 'return')
"         " echom 'excution finishs @ ' . strftime('%T')
"         return
"     endif
"     call job_start("echo '". l:name . "'", {'close_cb': 'async#AsyncFuncRun'})
" endfunction
