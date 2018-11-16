if has('win32')  || has('win64')
    let s:path_python = systemlist('where python')
else
    let s:path_python = systemlist('which python')
endif
let g:completor_python_binary = s:path_python[0]
