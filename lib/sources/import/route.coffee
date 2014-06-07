child_process = require 'child_process'
formidable = require 'formidable'
pinyin = require("pinyin");
nekoime = require '../../nekoime'

express = require("express")
router = express.Router()
router.post "/", (req, res) ->
  formidable.IncomingForm().parse req, (err, fields, files)->
    child_process.execFile './bin/nekoime-analyser', (file.path for key, file of files), (error, stdout, stderr)->
      return res.send 500, error.toString() if error
      nekoime.db.words.find {}, (err, docs)->
        return res.send 500, error.toString() if error
        old_words = {}
        for word in docs
          old_words[word.word] = true

        new_words = []

        lines = stdout.split "\n"
        lines.pop()

        words_count = lines.length
        for line in lines.sort()
          [word, frequencies] = line.split ' '

          #过滤 "哈哈哈哈" 一类重复字组成的词语，因为分析算法中没为这个单独处理，会导致词频偏高
          if word.length >= 3
            flag = false
            for char in word
              if char != word[0]
                flag = true
                break
            continue if not flag

          if not old_words[word]
            new_words.push
              word: word
              frequencies: parseInt frequencies
              pinyin: (p[0] for p in pinyin word, style: pinyin.STYLE_TONE2)
              updated_at: new Date()
              source: "import"

        nekoime.db.words.insert new_words, (err, newDocs)->
          return res.send 500, error.toString() if error
          res.send "识别了 #{words_count} 个词语, 导入了 #{new_words.length} 个新词"

          nekoime.save_words()

module.exports = router