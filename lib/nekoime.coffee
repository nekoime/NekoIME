fs = require 'fs'
path = require 'path'
child_process = require 'child_process'
pinyin = require 'pinyin'
request = require 'request'

Datastore = require('nedb')

nekoime = {}

nekoime.sources = (for source in fs.readdirSync('./lib/sources')
  result = require './sources/' + source + '/manifest.json'
  result.id = source
  #if fs.existsSync './lib/sources/' + source + 'view.html.mustache'
    #result.view = true
  if fs.existsSync './lib/sources/' + source + '/logo.png'
    result.logo = true
  if fs.existsSync './lib/sources/' + source + '/route.js'
    result.route = true
  result
)

nekoime.db = {}
home = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;


for db in ['words', 'user']
  nekoime.db[db] = new Datastore({ filename: "#{home}/.nekoime/#{db}.db", autoload: true });

nekoime.db.words.ensureIndex
  fieldName: 'word'
  unique: true

nekoime.backends = {}

for backend in fs.readdirSync('./lib/backends')
  nekoime.backends[backend] = require './backends/sunpinyin/backend'
  nekoime.backends[backend].id = backend
  if fs.existsSync './lib/backends/' + backend + '/route.js'
    nekoime.backends[backend].route = true

nekoime.login_check = (req, res, next)->
  nekoime.db.user.findOne {}, (err, doc)->
    return res.send 500, err.toString() if err
    if doc
      next()
    else
      res.redirect 'http://localhost:5285/login'

nekoime.update_profile = (callback)->
  nekoime.db.user.findOne {}, (err, doc)->
    return callback err if err
    return callback 'not logged in' if !doc
    request
      url: 'http://localhost:5285/profile'
      qs:
        token: doc.token
      json: true
    , (error, response, body)->
        #console.log body
        return callback error if error
        nekoime.db.user.update {}, {
          $set:
            profile: body
        }, (err)->
          return callback err if err
          callback()

#初始化读取

nekoime.backend = nekoime.backends.sunpinyin

nekoime.backend.load_words (dicts)->
  nekoime.db.words.find {}, (err, docs)->
    throw err if err
    old_words = {}
    for word in docs
      old_words[word.word] = true

    new_words = []
    now = new Date()
    for dict, words of dicts
      console.log dict, words.length
      for word in words when not old_words[word.word]
        new_words.push
          word: word.word
          frequencies: word.frequencies if word.frequencies
          pinyin: word.pinyin if word.pinyin
          updated_at: now
          source: "local:sunpinyin:#{dict}"
        old_words[word.word] = true
    if new_words.length
      nekoime.db.words.insert new_words, (err, newDocs)->

nekoime.save_words = ()->
  nekoime.db.words.find {$not: source: $regex: /^local:/}, (err, docs)->
    return callback err if err
    nekoime.backend.save_words docs, (err)->
      if err
        nekoime.notify '保存词库失败', err.toString()
      else
        nekoime.notify 'NekoIME', '本地输入法词库已更新'

nekoime.notify = (summary, body='')->
  child_process.execFile 'notify-send', ['--app-name=nekoime', "--icon=#{path.join process.cwd(), 'public/images/icon.png'}", summary, body]

nekoime.save_words()

module.exports = nekoime