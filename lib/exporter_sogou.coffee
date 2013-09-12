fs = require 'fs'
@update = (new_words, updated_words)->
  result = ""
  for word in new_words
    for pinyin in word.inputcode_pinyin
      result += "\'" + pinyin
    result += ' ' + word.word + "\n"
  new_words.join('\'')
  fs.appendFile '搜狗词库.txt', result
