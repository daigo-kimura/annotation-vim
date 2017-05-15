source plugin/ant.vim

describe 'This plugin'
  before
    new
      let g:annotation_vim_begin_tag   = '<opinion tag="graphic:p,">'
      let g:annotation_vim_end_tag     = '</opition>'
  end

  after
    close!
  end

  it 'annotates a sentence'
    for i in range(0, 5)
      execute 'normal!' 'i' . join([
      \   '初めまして',
      \ ], "\<Return>")

      normal! gg0
      execute 'normal' i . 'l'
      call ant#annotation()

      Expect getline(1) ==#
            \ g:annotation_vim_begin_tag
            \ . '初めまして'
            \ . g:annotation_vim_end_tag

      normal! uu
    endfor
  end

  it 'annotates an inline sentence ending with(。)'
    for i in range(0, 5)
      execute 'normal!' 'i' . join([
      \   '初めまして。こんにちは。いい天気ですね。',
      \ ], "\<Return>")

      normal! 0
      execute 'normal' (i + 6) . 'l'
      call ant#annotation()

      Expect getline('.') ==#
            \ '初めまして。'
            \ . g:annotation_vim_begin_tag
            \ . 'こんにちは。'
            \ . g:annotation_vim_end_tag
            \ . 'いい天気ですね。'

      normal! uu
    endfor
  end

  it 'annotates an inline sentence surronded(><)'
    for i in range(0, 4)
      execute 'normal!' 'i' . join([
      \   '>こんにちは<',
      \ ], "\<Return>")

      normal! 0
      execute 'normal' (i + 1) . 'l'
      call ant#annotation()

      Expect getline('.') ==#
            \   '>'
            \ . g:annotation_vim_begin_tag
            \ . 'こんにちは'
            \ . g:annotation_vim_end_tag
            \ . '<'

      normal! uu
    endfor
  end

  it 'annotates single inline sentence ending with(。) on top'
    for i in range(0, 5)
      execute 'normal!' 'i' . join([
      \   '初めまして。',
      \   '初めまして。',
      \ ], "\<Return>")

      normal! gg0
      execute 'normal' i . 'l'
      call ant#annotation()

      Expect getline(1) ==#
            \ g:annotation_vim_begin_tag
            \ . '初めまして。'
            \ . g:annotation_vim_end_tag

      Expect getline(2) ==#
            \ '初めまして。'

      normal! uu
    endfor
  end

  it 'annotates single inline sentence ending with(。) in middle'
    for i in range(0, 5)
      execute 'normal!' 'i' . join([
      \   '初めまして。',
      \   '初めまして。',
      \   '初めまして。',
      \ ], "\<Return>")

      normal! 0k
      execute 'normal' i . 'l'
      call ant#annotation()

      Expect getline('1') ==#
            \ '初めまして。'
      Expect getline('2') ==#
            \ g:annotation_vim_begin_tag
            \ . '初めまして。'
            \ . g:annotation_vim_end_tag

      Expect getline('3') ==#
            \   '初めまして。'

      normal! uu
    endfor
  end

  it 'annotates single inline sentence ending with(。) on bottom'
    for i in range(0, 5)
      execute 'normal!' 'i' . join([
      \   '初めまして。',
      \   '初めまして。',
      \ ], "\<Return>")

      normal! G0
      execute 'normal' i . 'l'
      call ant#annotation()

      Expect getline(1) ==#
            \ '初めまして。'
      Expect getline(2) ==# g:annotation_vim_begin_tag
            \ . '初めまして。'
            \ . g:annotation_vim_end_tag

      normal! uu
    endfor
  end

  it 'annotates several-lines-sentence ending with(。)'
    for i in range(0, 7)
      execute 'normal!' 'i' . join([
      \   '初めまして。こんにちは。今日は',
      \   'いい天気ですね。',
      \ ], "\<Return>")

      normal! 0
      execute 'normal' i . 'l'
      call ant#annotation()

      Expect getline(1) ==#
            \ '初めまして。こんにちは。'
            \ . g:annotation_vim_begin_tag
            \ . '今日は'
      Expect getline(2) ==#
            \ 'いい天気ですね。'
            \ . g:annotation_vim_end_tag

      normal! uuu
    endfor
  end

  it 'annotates a sentence preceeding xml tag'
    for i in range(0, 4)
      execute 'normal!' 'i' . join([
      \   '<sentence>',
      \   '初めまして',
      \   '</sentence>',
      \ ], "\<Return>")

      normal! ggj0
      execute 'normal' i . 'l'
      call ant#annotation()

      Expect getline(1) ==#
            \   '<sentence>'
      Expect getline(2) ==#
            \  g:annotation_vim_begin_tag
            \ . '初めまして'
            \ . g:annotation_vim_end_tag

      Expect getline(3) ==#
            \   '</sentence>'

      normal! uuu
    endfor
  end

  it 'annotates a sentence surrounded with blank lines'
    for i in range(0, 4)
      execute 'normal!' 'i' . join([
      \   '',
      \   '初めまして',
      \   '',
      \ ], "\<Return>")

      normal! ggj0
      execute 'normal' i . 'l'
      call ant#annotation()
      Expect getline(1) ==#
      \   ''
      Expect getline(2) ==#
            \ g:annotation_vim_begin_tag
            \ . '初めまして'
            \ . g:annotation_vim_end_tag

      Expect getline(3) ==#
            \   ''

      normal! uuu
    endfor
  end

  it 'annotates a several-lines-sentence surronded by(><)'
    for i in range(0, 7)
      execute 'normal!' 'i' . join([
            \   '初めまして。こんにちは<sentence>今日は',
            \   'いい天気ですね</sentence>',
            \ ], "\<Return>")

      normal! 0
      execute 'normal' i . 'l'
      call ant#annotation()

      Expect getline(1) ==#
            \   '初めまして。こんにちは<sentence>'
            \ . g:annotation_vim_begin_tag
            \ . '今日は'
      Expect getline(2) ==#
            \   'いい天気ですね'
            \ . g:annotation_vim_end_tag
            \ . '</sentence>'

      normal! uuu
    endfor
  end
end
