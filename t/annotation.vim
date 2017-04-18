source ant.vim

describe 'Annotation'
  before
    new
  end

  after
    close!
  end

  it 'annotate single inline sentence ending with(。)'
    for i in range(0, 5)
      execute 'normal!' 'i' . join([
      \   '初めまして。',
      \ ], "\<Return>")

      normal! 0
      execute 'normal' i . 'l'
      call ant#annotation()

      Expect getline('.') ==#
      \   '<opinion tag="graphic:p,">初めまして。</opinion>'

      normal! uu
    endfor
  end

  it 'annotate inline sentence ending with(。)'
    for i in range(0, 5)
      execute 'normal!' 'i' . join([
      \   '初めまして。こんにちは。いい天気ですね。',
      \ ], "\<Return>")

      normal! 0
      execute 'normal' (i + 6) . 'l'
      call ant#annotation()

      Expect getline('.') ==#
      \   '初めまして。<opinion tag="graphic:p,">こんにちは。</opinion>いい天気ですね。'

      normal! uu
    endfor
  end

  it 'annotate inline sentence guillemet'
    for i in range(0, 4)
      execute 'normal!' 'i' . join([
      \   '>こんにちは<',
      \ ], "\<Return>")

      normal! 0
      execute 'normal' (i + 1) . 'l'
      call ant#annotation()

      Expect getline('.') ==#
      \   '><opinion tag="graphic:p,">こんにちは</opinion><'

      normal! uu
    endfor
  end

  it 'annotate several-lines-sentence ending with(。)'
    for i in range(0, 7)
      execute 'normal!' 'i' . join([
      \   '初めまして。こんにちは。今日は',
      \   'いい天気ですね。',
      \ ], "\<Return>")

      normal! 0
      execute 'normal' i . 'l'
      call ant#annotation()

      Expect getline(1) ==#
      \   '初めまして。こんにちは。<opinion tag="graphic:p,">今日は'
      Expect getline(2) ==#
      \   'いい天気ですね。</opinion>'

      normal! uuu
    endfor
  end

  it 'annotate several-lines-sentence surronded by(><)'
    for i in range(0, 7)
      execute 'normal!' 'i' . join([
      \   '初めまして。こんにちは>今日は',
      \   'いい天気ですね<',
      \ ], "\<Return>")

      normal! 0
      execute 'normal' i . 'l'
      call ant#annotation()

      Expect getline(1) ==#
      \   '初めまして。こんにちは><opinion tag="graphic:p,">今日は'
      Expect getline(2) ==#
      \   'いい天気ですね</opinion><'

      normal! uuu
    endfor
  end
end
