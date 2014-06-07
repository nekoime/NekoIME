nekoime = require '../lib/nekoime'

express = require("express")
router = express.Router()


accentsMap =
  iao: 'ia*o', uai: 'ua*i',
  ai: 'a*i', ao: 'a*o', ei: 'e*i', ia: 'ia*',  ie: 'ie*',
  io: 'io*', iu: 'iu*', Ai: 'A*i', Ao: 'A*o', Ei: 'E*i',
  ou: 'o*u', ua: 'ua*',  ue: 'ue*', ui: 'ui*', uo: 'uo*',
  ve: 'üe*', Ou: 'O*u',
  a: 'a*', e: 'e*', i: 'i*', o: 'o*', u: 'u*', v: 'v*',
  A: 'A*', E: 'E*', O: 'O*'


# Vowels to replace with their accented froms
vowels = ['a*','e*','i*','o*','u*','v*','A*','E*','O*']

# Accented characters for each of the four tones
pinyin =
  1: ['ā','ē','ī','ō','ū','ǖ','Ā','Ē','Ī','Ō'],
  2: ['á','é','í','ó','ú','ǘ','Á','É','Í','Ó'],
  3: ['ǎ','ě','ǐ','ǒ','ǔ','ǚ','Ǎ','Ě','Ǐ','Ǒ'],
  4: ['à','è','ì','ò','ù','ǜ','À','È','Ì','Ò']

pinyinReplace = (match) ->

  # Extract the tone number from the match
  toneNumber = match.substr(-1, 1)

  # Extract just the syllable
  word = match.substring(0, match.indexOf(toneNumber))

  # Put an asterisk inside of the first found vowel cluster
  for val of accentsMap
    unless word.search(val) is -1
      word = word.replace(new RegExp(val), accentsMap[val])
      break

  # Replace the asterisk’d vowel with an accented character
  i = 0
  while i < 10
    word = word.replace(vowels[i], pinyin[toneNumber][i])
    i++

  # Return the result
  word


# GET home page.
router.get "/", nekoime.login_check, (req, res) ->
  if req.accepts('application/json', 'text/html') == 'application/json'
    console.log req.query
    if req.query.search.value.length
      query = nekoime.db.words.find word: $regex: new RegExp(req.query.search.value)
    else
      query = nekoime.db.words.find {}

    for order in req.query.order
      sort = {}
      sort[req.query.columns[order.column].name] = if order.dir == 'desc' then -1 else 1
      console.log sort
      query.sort sort


    query.skip parseInt req.query.start
    query.limit parseInt req.query.length

    query.exec (err, docs)->
      return res.send 500, err.toString() if err
      nekoime.db.words.count {}, (err, count)->
        return res.send 500, err.toString() if err
        res.send
          draw: req.query.draw
          recordsTotal: count
          recordsFiltered: count
          data: (for word in docs
            console.log word.pinyin
            word.updated_at = "#{word.updated_at.getFullYear()}-#{word.updated_at.getMonth() + 1}-#{word.updated_at.getDate()} #{word.updated_at.getHours()}:#{word.updated_at.getMinutes()}:#{word.updated_at.getSeconds()}"
            word.pinyin = ((if /^([a-zA-Z]+)([1-5])$/.test(p) then pinyinReplace(p) else p) for p in word.pinyin).join(' ') if word.pinyin
            (word[column.name] for column in req.query.columns)
          )



  else
    res.render "words"
    #.exec
    #  words = docs
    #  for word in words
    #    word.updated_at = "#{word.updated_at.getFullYear()}-#{word.updated_at.getMonth() + 1}-#{word.updated_at.getDate()} #{word.updated_at.getHours()}:#{word.updated_at.getMinutes()}:#{word.updated_at.getSeconds()}"
    #  ,
    #    words: docs
    #    #if sort_words

module.exports = router