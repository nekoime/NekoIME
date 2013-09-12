#MongoClient = require('mongodb').MongoClient

spider_moegirlwiki = require './lib/spider_moegirlwiki'
analyzer = require './lib/analyzer'
transcoder_pinyin = require './lib/transcoder_pinyin'
exporter_sogou = require './lib/exporter_sogou'
exporter_google = require './lib/exporter_google'
exporter_sunpinyin = require './lib/exporter_sunpinyin'

#type:article, tag, username
#MongoClient.connect 'mongodb://master.my-card.in:27017/NekoIME', (err, db)->
#  throw err if err

exporter_sunpinyin.start()
setImmediate ->
  #articles = db.collection('articles')
  #words = db.collection('articles')
  spider_moegirlwiki.start (from, text, type, weight=1)->
    #articles.insert text: text, type: type, weight: weight, from: from, (err, docs)->
#      throw err if err
      analyzer.analyze null, text, type, weight, (new_words, updated_words)->
        new_words.forEach (word)->
          word.inputcode_pinyin = transcoder_pinyin.transcode word.word
          #words.insert word
        #for word in updated_words
          #words.findAndModify word:word, 'word', weight: $inc: word.weight_relative
        #exporter_sogou.update(new_words, updated_words)
        #exporter_google.update(new_words, updated_words)
        exporter_sunpinyin.update(new_words, updated_words)








