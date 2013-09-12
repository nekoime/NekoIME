fs = require 'fs'
spawn = require('child_process').spawn

words = []
@start = ->
  setInterval @do_update, 3600 #000
@update = (new_words)->
  words = words.concat new_words
@do_update = ->
  return unless words.length
  result = ("#{word.word}\t#{word.weight}\t#{word.inputcode_pinyin.join(' ')}\n" for word in words).join('')
  #console.log result
  words = []
  fs.appendFile 'result.dic', result, ->
    iconv = spawn 'iconv', ['-f', 'utf-8', '-t', 'gb18030', '-o', 'result_gb18030.dic', 'result.dic']
    iconv.on 'close', (code)->
      if code != 0
        console.log 'iconv process exited with code ' + code
      else
        fs.unlink 'result.dic', ->
        kill_ibus = spawn 'killall', ['ibus-daemon']
        kill_ibus.on 'close', (code)->
          importer = spawn 'lib/sunpinyin_importer/import_google_userdict.py', ['result_gb18030.dic']
          importer.stdout.on 'data', (data)->
            console.log 'stdout: ' + data
          importer.stderr.on 'data', (data)->
            console.log 'stderr: ' + data

          importer.on 'close', (code)->
            if code != 0
              console.log 'importer process exited with code ' + code
            spawn 'ibus-daemon', ['-d']
            fs.unlink 'result_gb18030.dic'
            console.log 'exported'


