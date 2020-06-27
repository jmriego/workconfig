augroup netrw_mapping
  autocmd!
  autocmd filetype netrw call NetrwMapping()
augroup END

" make sure netrw does not overwrite c-h and c-l mappings
function! NetrwMapping()
  silent! nunmap <buffer> <c-h>
  silent! nunmap <buffer> <c-l>
endfunction

