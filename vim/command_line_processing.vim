func CommandLineProcessing()
    let cmd = getcmdline()
    call histadd("cmd", cmd)

    if cmd =~ "^Git push"
        let git_status_win = bufwinid('.git/')
        let timer_id = timer_start(500, function('win_execute', [git_status_win, 'close']))
        return substitute(cmd, "Git", "Dispatch git", "")
    elseif cmd =~ "^Git fetch"
       return substitute(cmd, "Git", "Dispatch git", "")
    elseif cmd =~ "^Ag$"
       return cmd . " " . expand("<cword>")
    else
        return cmd
    endif
endfunc
