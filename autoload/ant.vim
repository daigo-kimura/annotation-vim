"""""""""""""""""""""""""""""""""""""""""""
" カーソル下の文を<opinion></opinion>で囲む
"""""""""""""""""""""""""""""""""""""""""""

scriptencoding utf-8

if !exists('g:annotation_vim_loaded')
r finish
endif

let g:annotation_vim_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

let g:annotation_vim_begin_tag  = '<opinion tag="graphic:p,">'
let g:annotation_vim_end_tag = '</opinion>'
let g:annotation_vim_show_log = 0
let g:annotation_vim_current_buf_name = bufnr('%')
let g:annotation_vim_menu_buf_name = -1
let g:annotation_vim_attributes = ['graphic']
let g:annotation_vim_config = {}
let g:annotation_vim_config_loaded = 0
let g:annotation_vim_config_file_name = '.annotation_vim_config'
let g:annotation_vim_checkbox_pos = {}


function! ant#is_multibyte(code)
  if a:code < 128
    return 0
  else
    return 1
  endif
endfunction


function! ant#split_multibyte(sentence)
  return split(a:sentence, '\zs')
endfunction


function! ant#get_current_col()
  let l:line = ant#split_multibyte(getline("."))
  let l:n_byte = 1
  let l:count = 1

  for l:s in l:line
    if n_byte >= col(".")
      break
    endif

    let l:code = char2nr(l:s)
    " 127 < charならcharはマルチバイト?
    if ant#is_multibyte(l:code)
      let l:n_byte += 3
    else
      let l:n_byte += 1
    endif

    let l:count += 1
  endfor

  return l:count
endfunction


"""
" return if a:char in a:list
"""
function! ant#contain_str(list, char)
  for l:l in a:list
    if l:l == a:char
      return 1
    endif
  endfor
  return 0
endfunction


function! ant#load_config()
  if g:annotation_vim_config_loaded
    return
  endif
  let l:config_file_path = g:annotation_vim_config_file_dir . g:annotation_vim_config_file_name

  if !filereadable(l:config_file_path)
    let l:tag = { 'begin_tag': '<opinion tag="graphic:p,">', 'end_tag'  : '</opinion>', }
    let g:annotation_vim_attributes = ['graphic']
  else
    let l:config_file = readfile(l:config_file_path)
    execute 'let l:tag =' . l:config_file[0]

    let g:annotation_vim_attributes = []
    for l:a in split(l:config_file[1], ',')
      if l:a != ''
        let g:annotation_vim_attributes = add(g:annotation_vim_attributes, l:a)
      endif
    endfor
  endif

  if g:annotation_vim_show_log
    echo l:tag
  endif

  let g:annotation_vim_begin_tag = l:tag['begin_tag']
  let g:annotation_vim_end_tag = l:tag['end_tag']

  call ant#tag_to_config()

  let g:annotation_vim_config_loaded = 1
endfunction


function! ant#store_config()
  let l:output = ["{ 'begin_tag': '"
        \ . g:annotation_vim_begin_tag
        \ . "', 'end_tag': '"
        \ . g:annotation_vim_end_tag
        \ . "' }",
        \ join(g:annotation_vim_attributes, ','),
        \ ]
  let l:config_file_path = g:annotation_vim_config_file_dir . g:annotation_vim_config_file_name
  call writefile(l:output, l:config_file_path)
endfunction


function! ant#tag_to_config()
  let l:value_tag = substitute(g:annotation_vim_begin_tag, '\(^<.\+ tag=\"\|,\">$\)', '', 'g')
  let l:tag = {}
  for l:t in split(l:value_tag, ',')
    let l:tmp = split(l:t, ':')
    let l:att = l:tmp[0]
    let l:pol = l:tmp[1]
    let l:tag[l:att] = l:pol
  endfor

  for l:att in g:annotation_vim_attributes
    if !has_key(l:tag, l:att) || l:tag[l:att] == 'x'
      let g:annotation_vim_config[l:att] = 'x'
    elseif l:tag[l:att] == 'p'
      let g:annotation_vim_config[l:att] = 'p'
    elseif l:tag[l:att] == 'n'
      let g:annotation_vim_config[l:att] = 'n'
    else
      let g:annotation_vim_config[l:att] = '?'
    endif
  endfor
endfunction


function! ant#config_to_tag()
  let g:annotation_vim_begin_tag = '<opinion tag="'
  for l:att in g:annotation_vim_attributes
    let g:annotation_vim_begin_tag .= l:att . ':'
          \ . g:annotation_vim_config[l:att]
          \ . ','
  endfor
  let g:annotation_vim_begin_tag .= '">'
  echo g:annotation_vim_begin_tag
endfunction


function! ant#annotation()
  call ant#load_config()
  let l:line = ant#split_multibyte(getline("."))
  let l:cursor_pos = getpos('.')

  " この記号を含んで囲む
  let l:punctuations = ['。', '！',]
  " この記号を含まず囲む
  let l:guillemets = ['<', '>',]

  let l:found = 0
  let l:search_line = l:line
  let l:search_row = l:cursor_pos[1]
  let l:search_col = ant#get_current_col() - 1
  let l:prev_cursor_col = l:search_col + 1
  let l:in_same_line = 1
  let l:insert_head = 0

  if g:annotation_vim_show_log
    echo "Search preceeding char: "
    echo l:search_line
    echo 'row: ' . l:search_row
    echo 'col: ' . l:search_col
  endif

  while !l:found
    while l:search_col >= 1
      if g:annotation_vim_show_log
        echo 'Searching: ' . l:search_col . ' => ' . l:search_line[l:search_col - 1]
      endif

      if ant#contain_str(l:punctuations, l:search_line[l:search_col - 1])
            \ || ant#contain_str(l:guillemets, l:search_line[l:search_col - 1])
        let l:found = 1

        if !l:in_same_line && l:search_col == len(l:search_line)
          " 上の行の最右列がdelimiterだった場合
          let l:insert_head = 1
          let l:search_row += 1
          let l:search_col = 1
          let l:search_line = ant#split_multibyte(getline(l:search_row))
        endif
        break
      endif

      let l:search_col -= 1
    endwhile

    if l:found
      if l:insert_head
        let l:replace = g:annotation_vim_begin_tag
              \ . join(l:search_line, "")
      else
        let l:replace = join(l:search_line[0: l:search_col - 1], "")
              \ . g:annotation_vim_begin_tag
              \ . join(l:search_line[l:search_col: ], "")
      endif

      call setline(l:search_row, l:replace)
      break
    else
      if l:search_row == 1
            \ || len(ant#split_multibyte(getline(l:search_row - 1))) == 0
        " 検索対象が最上行 || 一つ下の行が空行
        let l:replace = g:annotation_vim_begin_tag
              \ . join(l:search_line, "")
        call setline(l:search_row, l:replace)
        break
      endif

      " 検索対象を上の行に
      let l:search_row -= 1
      let l:search_line = ant#split_multibyte(getline(l:search_row))
      let l:search_col = len(l:search_line)
      let l:in_same_line = 0
      if g:annotation_vim_show_log
        echo 'Move up'
      endif
    endif
  endwhile

  let l:found = 0
  let l:insert_tail = 0
  let l:in_same_line = 1
  let l:buf_line_len = len(getline(0, '$'))
  let l:search_line = ant#split_multibyte(getline("."))
  if l:cursor_pos[1] == l:search_row
    let l:search_col = len(l:search_line) - (len(l:line) - l:prev_cursor_col)

    if g:annotation_vim_show_log
      echo 'Initialize: '
      echo len(l:search_line)
      echo len(l:line)
      echo ant#get_current_col()
    endif
  else
    let l:search_col = ant#get_current_col()
  endif
  let l:search_row = l:cursor_pos[1]

  if g:annotation_vim_show_log
    echo "Search following char: "
    let l:output = []
    for l:i in range(1, len(l:search_line))
      call add(l:output, l:i . ': ' . l:search_line[l:i - 1])
    endfor
    echo join(l:output, ', ')
    echo 'row: ' . l:search_row
    echo 'col: ' . l:search_col
  endif

  while !l:found
    while l:search_col <= len(l:search_line)
      if g:annotation_vim_show_log
        echo 'Searching: ' . l:search_col . ' => ' . l:search_line[l:search_col - 1]
      endif

      if ant#contain_str(l:punctuations, l:search_line[l:search_col - 1])
        let l:found = 1
        break
      endif

      if ant#contain_str(l:guillemets, l:search_line[l:search_col - 1])
        let l:found = 1
        let l:search_col -= 1

        if !l:in_same_line && l:search_col == 0
          " 下の行の最左列がguillemetsだった場合
          let l:insert_tail = 1
          let l:search_row -= 1
          let l:search_line = ant#split_multibyte(getline(l:search_row))
          let l:search_col = len(l:search_line)
        endif
        break
      endif

      let l:search_col += 1
    endwhile

    if l:found
      if l:insert_tail
        let l:replace = join(l:search_line, "")
              \ . g:annotation_vim_end_tag
      else
        let l:replace = join(l:search_line[0: l:search_col - 1], "")
              \ . g:annotation_vim_end_tag
              \ . join(l:search_line[l:search_col: ], "")
      endif

      call setline(search_row, replace)
      break
    else
      if l:search_row == buf_line_len
            \ || len(ant#split_multibyte(getline(l:search_row + 1))) == 0
        " 検索対象が最下行 || 検索対象の一つ下の行が空行
        let l:replace = join(l:search_line, "")
              \ . g:annotation_vim_end_tag
        call setline(l:search_row, l:replace)
        break
      endif

      " 検索対象を下の行に
      let l:search_row += 1
      let l:search_line = ant#split_multibyte(getline(l:search_row))
      let l:search_col = 1
      let l:in_same_line = 0
      if g:annotation_vim_show_log
        echo 'Move down'
      endif
    endif
  endwhile
endfunction


function! ant#update_menu()

  setlocal modifiable
  call setline(1, g:annotation_vim_begin_tag . '....SENTENCE....' . g:annotation_vim_end_tag)
  call setline(2, '')

  let l:output = ''
  let l:count = 0
  for l:att in g:annotation_vim_attributes
    let l:o = l:att . '[ '
          \ .  g:annotation_vim_config[l:att]
          \ . ' ]  '
    let l:output .= l:o
    let g:annotation_vim_checkbox_pos[l:att] = l:count + strlen(l:att) + 1
    let l:count += strlen(l:o)
  endfor

  call setline(3, l:output)
  setlocal nomodifiable
endfunction


function! ant#toggle_menu()
  if bufexists(g:annotation_vim_menu_buf_name)
    let l:nr = bufwinnr(g:annotation_vim_menu_buf_name)
    execute l:nr . 'wincmd w'
    execute 'q'
    let g:annotation_vim_menu_buf_name = -1
    return
  endif

  execute '5new'

  setlocal noshowcmd
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=delete
  setlocal nobuflisted
  setlocal nowrap
  setlocal nonumber
  map <buffer> <silent> <2-LeftMouse> <LeftMouse>
  map <buffer> <silent> <3-LeftMouse> <LeftMouse>

  let g:annotation_vim_menu_buf_name = bufnr('%')

  call ant#load_config()
  call ant#update_menu()

  let l:nr = bufwinnr(g:annotation_vim_current_buf_name)
  execute l:nr . 'wincmd w'
endfunction


function! ant#change_polarity(att)
  if g:annotation_vim_config[a:att] == 'p'
    let g:annotation_vim_config[a:att] = 'n'
  elseif g:annotation_vim_config[a:att] == 'n'
    let g:annotation_vim_config[a:att] = 'x'
  elseif g:annotation_vim_config[a:att] == 'x'
    let g:annotation_vim_config[a:att] = 'p'
  elseif g:annotation_vim_config[a:att] == '?'
    let g:annotation_vim_config[a:att] = 'p'
  endif
endfunction


function! ant#check_box()
  let l:row = getpos('.')[1]
  let l:col = getpos('.')[2]

  if l:row == 1
    return
  endif

  for l:att in g:annotation_vim_attributes
    if g:annotation_vim_checkbox_pos[l:att] <= l:col
          \ && l:col <= g:annotation_vim_checkbox_pos[l:att] + 5
      call ant#change_polarity(l:att)
      call ant#config_to_tag()
      call ant#store_config()
      call ant#update_menu()
      return
    endif
  endfor
endfunction


function! ant#on_click()
  if bufnr('%') != g:annotation_vim_menu_buf_name
    return
  endif

  if g:annotation_vim_menu_buf_name == -1
    return
  endif

  call ant#check_box()

  let l:nr = bufwinnr(g:annotation_vim_current_buf_name)
  execute l:nr . 'wincmd w'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
