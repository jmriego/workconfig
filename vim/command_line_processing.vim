func CommandLineProcessing()
    let cmd = getcmdline()
    call histadd("cmd", cmd)
    if cmd =~ "^Git push" || cmd =~ "^Git fetch"
        let cmd = substitute(cmd, "Git", "Dispatch git", "")
    endif
    return cmd
endfunc
