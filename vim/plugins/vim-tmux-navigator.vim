augroup netrw_mapping
  autocmd!
  autocmd filetype netrw call NetrwMapping()
augroup END

" make sure netrw does not overwrite c-h and c-l mappings
function! NetrwMapping()
  nunmap <buffer> <c-h>
  nunmap <buffer> <c-l>
endfunction
