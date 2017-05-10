"""""""""""""""""""""""""""""""""""""""""""
" カーソル下の文を<opinion></opinion>で囲む
"""""""""""""""""""""""""""""""""""""""""""

scriptencoding utf-8

if exists('g:annotation_vim_loaded')
    finish
endif
let g:annotation_vim_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

let g:annotation_vim_show_log = 0
let g:annotation_vim_config_file_dir = expand('~/.config/')

nnoremap <silent> <Leader>f :<C-u>call ant#annotation()<CR>
noremap <silent> <LeftMouse> <LeftMouse>:<C-u>call ant#on_click()<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
