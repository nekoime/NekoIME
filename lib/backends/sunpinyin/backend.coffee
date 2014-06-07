fs = require 'fs'
child_process = require 'child_process'
pinyin = require 'pinyin'
tmp = require 'tmp'
tmp.setGracefulCleanup();

sunpinyin = {}

env = process.env
env.PYTHONIOENCODING = 'utf-8'

sunpinyin.load_words = (callback)->
  result = {}
  child_process.execFile 'python2', ['./lib/backends/sunpinyin/python/importer/importer.py'], maxBuffer: 200*1024*1024, (error, stdout, stderr)->
    throw error if error
    lines = stdout.split "\n"
    lines.pop()
    result.user = (for line in lines
      [word, frequencies, p] = line.split ' '
      word: word
      frequencies: parseInt frequencies
      pinyin: p.split "'"
    )
    child_process.execFile 'python2', ['./lib/backends/sunpinyin/python/importer/system_dict.py'], maxBuffer: 200*1024*1024, (error, stdout, stderr)->
      throw error if error
      lines = stdout.split "\n"
      lines.pop()
      result.system = (for line in lines
        word: line
      )
      callback result

sunpinyin.save_words = (words, callback)->
  return callback() if words.length == 0
  tmp.tmpName (err, path)->
    return callback err if err

    fs.writeFile path, (for word in words when 2 <= word.word.length <= 6
      if word.pinyin
        word.pinyin = (p.match(/[A-Za-z]+/)[0] for p in word.pinyin)
      else
        word.pinyin = (p[0] for p in pinyin word.word, style: pinyin.STYLE_NORMAL)

      "#{word.pinyin.join("'")} #{word.word}").join("\n"), (err)->
        console.log path
        return callback err if err
        child_process.execFile 'python2', ['./lib/backends/sunpinyin/python/importer/import_qim_userdict.py', path], maxBuffer: 200*1024*1024, env: env, (error, stdout, stderr)->
          return callback error if error
          console.log stdout
          child_process.execFile 'killall', ['fcitx'], (error, stdout, stderr)->
            return callback error if error
            child_process.execFile 'fcitx', ['-r']
            callback()

module.exports = sunpinyin
