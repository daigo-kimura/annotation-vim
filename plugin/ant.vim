"""""""""""""""""""""""""""""""""""""""""""
" カーソル下の文を<opinion></opinion>で囲む
"""""""""""""""""""""""""""""""""""""""""""

scriptencoding utf-8

if exists('g:annotation_vim_loaded')
    finish
endif
let g:annotation_vim_loaded = 1

nnoremap <silent> <Leader>f :<C-u>call ant#annotation()<CR>
