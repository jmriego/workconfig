autocmd BufRead,BufNewFile *.wiki set nowrap
autocmd FileType vimwiki autocmd BufWritePost <buffer> silent Vimwiki2HTML
