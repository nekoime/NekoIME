fs = require 'fs'
ffi = require 'ffi'
@start = ->
  fs.exists 'result.dic', (exists)->
    fs.writeFile 'result.dic', '\xEF\xBB\xBF', encoding: 'ascii' if !exists
@update = (new_words, updated_words)->
  result = ("#{word.word}\t#{word.weight}\t#{word.inputcode_pinyin.join(' ')}\n" for word in new_words).join('')
  fs.appendFile 'result.dic', result
  #gpy_dict_api = ffi.Library 'C:\\Program Files (x86)\\Google\\Google Pinyin 2\\gpy_dict_api.dll',
  #  ImportDictionary: [ 'bool', [ 'string' ] ]
  #gpy_dict_api.ImportDictionary('result.dic')
  #ffi.DynamicLibrary 'gpy_dict_api.dll', ffi.DynamicLibrary.FLAGS.RTLD_LOCAL


gpy_dict_api = ffi.DynamicLibrary 'C:\\Program Files (x86)\\Google\\Google Pinyin 2\\gpy_dict_api.dll', ffi.DynamicLibrary.FLAGS.RTLD_GLOBAL
