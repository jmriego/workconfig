if exists(":CompilerSet") != 2    " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let current_compiler = "dbt"
CompilerSet makeprg=dbt\ $*

let b:context_errorformat = ''
    \ . '%-GRunning with dbt%.%#,'
    \ . '%-GFound%.%#models%.%#,'
    \ . '%-G %#%.%#,'
    \ . '%-G%#%.%#,'
    \ . '%-G%.%#Concurrency%.%#threads%.%#,'
    \ . '%-G%[0-9: ]%.%#|,'
    \ . '%-G%[0-9: ]%.%#| Done.,'
    \ . '%-GEncountered an error:,'
    \ . '%ECompilation Error %.%#(%f),'
    \ . '%EDatabase Error %.%#(%f),'
    \ . '%ERuntime Error %.%#(%f),'
    \ . '%ESyntax error %.%#,'

execute 'CompilerSet errorformat=' . escape(b:context_errorformat, ' |')
