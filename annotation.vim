"""""""""""""""""""""""""""""""""""""""""""
" カーソル下の文を<opinion></opinion>で囲む
"""""""""""""""""""""""""""""""""""""""""""

let s:begin_tag = '<opinion tag="graphic:p,">'
let s:end_tag   = '</opinion>'

function! s:is_multibyte(code)
  if a:code < 128
    return 0
  else
    return 1
  endif
endfunction

function! s:get_current_col()
  let l:line = split(getline("."), '\zs')
  let l:n_byte = 1
  let l:count = 1

  for l:s in l:line
    if n_byte >= col(".")
      break
    endif

    let l:code = char2nr(l:s)
    " 127 < charならcharはマルチバイト?
    if s:is_multibyte(l:code)
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
function! s:contain_str(list, char)
  for l:l in a:list
    " echo 'contain_str: ' . l:l
    if l:l == a:char
      return 1
    endif
  endfor
  return 0
endfunction

function! s:dump_list(list)
  echo 'Dump list'
  l:l c = 0
  for l:i in range(0, len(a:list) - 1)
    echo l:i . ": " . a:list[l:i]
  endfor
endfunction


" TODO: 複数行に渡って書かれた文をどうする？
function! MyAnnotation()
  let l:line = split(getline("."), '\zs')
  let l:row = getpos('.')[1]

  let l:before_char = l:line[0: s:get_current_col() - 1]
  let l:before_char_len = len(l:before_char)
  let l:after_char = l:line[s:get_current_col(): ]
  let l:delimiters = ['。', '！', '<', '>',]

  " s:dump_list(l:line)

  let l:i = s:get_current_col() - 1
  while 0 <= l:i
    echo

    if s:contain_str(l:delimiters, l:before_char[l:i]) || l:i == 0
      echo 'Found(begin): ' . l:i . ' => ' . l:before_char[l:i]
      break
    endif
    echo "Search(begin): " . l:i . ' => ' . l:before_char[l:i]
    let l:i -= 1
  endwhile

  if l:i == 0
    " 文頭が上の行にある
    let l:before_char =  s:begin_tag . join(l:before_char, "")
  else
    let l:before_char = join(l:before_char[0: l:i], "")
          \ . s:begin_tag
          \ . join(l:before_char[l:i + 1: ], "")
  endif

  let l:i = 0
  let l:length = len(l:after_char)
  while l:i < l:length
    if s:contain_str(l:delimiters, l:after_char[l:i])
      echo "Found(after): " . l:i . ' => ' . l:after_char[l:i]
      break
    endif
    echo "Search(after): " . l:i . ' => ' . l:after_char[l:i]
    let l:i += 1
  endwhile

  if l:i == 0
  else
    let l:after_char = join(l:after_char[0: l:i - 1], "")
          \ . s:end_tag
          \ . join(l:after_char[l:i + 0: ], "")
  endif
  call setline(".", l:before_char . l:after_char)
endfunction

nnoremap <Leader>f :<C-u>call MyAnnotation()<CR>
