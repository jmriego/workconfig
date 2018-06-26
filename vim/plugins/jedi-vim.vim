let g:jedi#auto_vim_configuration = 0
"let g:jedi#force_py_version = "3"
let g:jedi#popup_select_first = 0
let g:jedi#completions_enabled = 0
let g:jedi#smart_auto_mappings = 0
let g:jedi#auto_close_doc = 0
let g:jedi#documentation_command = "<leader>D"
let g:jedi#usages_command = "<leader>u"
let g:jedi#goto_assignments_command = ""
let g:jedi#goto_command = "<leader>g"
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = 0

autocmd FileType python setlocal omnifunc=jedi#completions
