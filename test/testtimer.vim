function s:testfunction(...)
    " echo a:000
    echo a:2
endfunction

call timer_start(100, function('s:testfunction', ['1', [1,2,3]]))
