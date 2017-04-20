source plugin/ant.vim

describe 'My modules'
  it 'can split sentence containing multibyte char'
    let i = 0
    let sentence = 'こaaんにちbbbは'
    let chars = ant#split_multibyte(sentence)
    let string = ['こ', 'a', 'a', 'ん', 'に', 'ち', 'b', 'b', 'b', 'は']
    for i in range(0, len(chars) - 1)
      Expect chars[i] ==# string[i]
    endfor
  end

 it 'can get position on sentence containing multibyte'
    let sentence = 'こaaんにちbbbは'
    put! = 'こaaんにちbbbは'
    normal! gg0
    for i in range(0, len(ant#split_multibyte(sentence)) - 1)
      Expect i ==# ant#get_current_col() - 1
      normal! l
    endfor

    normal gg0l
    Expect 2 !=# col('.')
 end
end

