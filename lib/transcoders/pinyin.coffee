pinyin = require("pinyinjs")

Server.registerTranscoder name:'pinyin'

Server.on 'Transcoder.run',(item)->
  console.log word
module.exports = (word)->
  pinyin word,
    style: pinyin.STYLE_NORMAL
