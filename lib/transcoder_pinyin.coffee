pinyin = require("pinyinjs")
@transcode = (word)->
  pinyin word,
    style: pinyin.STYLE_NORMAL
