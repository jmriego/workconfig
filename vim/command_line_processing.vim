func CommandLineProcessing()
    let cmd = getcmdline()
    if cmd =~ "^Git push" || cmd =~ "^Git fetch"
        let cmd = substitute(cmd, "Git", "Dispatch git", "")
    endif
    return cmd
endfunc
