source annotation.vim

describe 'Annotation'

  before
    normal! ggVGd
  end

  it 'annotate single inline sentence ending with(。)'
    execute 'normal!' 'i' . join([
    \   '初めまして。',
    \ ], "\<Return>")

    normal! 0
    call MyAnnotation()

    Expect getline(1, '$') ==# [
    \   '<opinion tag="graphic:p,">初めまして。</opinion>',
    \ ]
  end

  it 'annotate inline sentence ending with(。)'
    execute 'normal!' 'i' . join([
    \   '初めまして。こんにちは。いい天気ですね。',
    \ ], "\<Return>")

    normal! 06l
    call MyAnnotation()

    Expect getline(1, '$') ==# [
    \   '初めまして。<opinion tag="graphic:p,">こんにちは。</opinion>いい天気ですね。',
    \ ]
  end

  it 'annotate inline sentence guillemet'
    execute 'normal!' 'i' . join([
    \   '>こんにちは<',
    \ ], "\<Return>")

    normal! hh
    call MyAnnotation()

    Expect getline(1, '$') ==# [
    \   '><opinion tag="graphic:p,">こんにちは</opinion><',
    \ ]
    normal!
  end
end
