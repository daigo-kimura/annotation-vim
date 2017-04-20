"""""""""""""""""""""""""""""""""""""""""""
" カーソル下の文を<opinion></opinion>で囲む
"""""""""""""""""""""""""""""""""""""""""""

scriptencoding utf-8

if exists("g:ant#loaded")
    finish
endif

let g:ant#loaded = 1
let s:save_cpo   = &cpo

nnoremap <Leader>f :<C-u>call ant#annotation()<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
