#! /usr/bin/env coffee

fs = require 'fs'

OpenCC = require('opencc');
opencc = new OpenCC('t2s.json');

_ = require('underscore');
_.str = require('underscore.string');
_.mixin(_.str.exports());


max_length = 6 #最大长度
min_frequencies = 20 #最小词频
min_cohesion = 300 #最小凝固度, 参考 http://www.matrix67.com/blog/archives/5044
min_entropy = 100 #自由程度， 同上

#求一个词的可能的组合，只想到了递归实现，于是写成函数了
#"喵帕斯" => ["喵", "帕", "斯"], ["喵帕", "斯"], ["喵", "帕斯"]
combinations = (word, allow_whole = false)->
  result = []
  for i in [1..(if allow_whole then word.length else word.length - 1)]
    first_part = word.slice(0, i)
    if i == word.length
      result.push [word]
    else
      rest_part = combinations word.slice(i), true
      for s in rest_part
        s.unshift(first_part)
        result.push s
  result

if process.argv[0]
  console.error "load #{process.argv.length - 2} files"
  words = {} #{word: count}
  sentences = []
  for file in process.argv.slice(2)
    article = fs.readFileSync file, encoding: 'utf8'
    article = opencc.convertSync(article) #如果要禁用繁简转换，注释掉这一行

    #[\u4E00-\u9FA5]是中文所在范围
    for sentence in article.split /[^\u4E00-\u9FA5]+/ when sentence.length > 0
      sentences.push sentence

      #求长度在 max_length 以下的所有子串，例如 "喵帕斯" 的子串有 "喵", "帕", "斯", "喵帕", "帕斯", "喵帕斯"
      for length in [1..Math.min(max_length, sentence.length)]
        for i in [0..sentence.length - length]
          word = sentence.substr(i, length)
          if words[word]
            words[word]++
          else
            words[word] = 1

  console.error "load #{sentences.length} sentences"

  #重算一下全由一个字构成的词的词频，因为上面遍历出来的会导致有些词的词频增加，例如 "啊啊啊啊啊啊"应该只包含 2 个"啊啊啊"，但是按上面的方法拆分之后变成 4 个了

  for word of words when words.length >= 2 and _.count(words, words[0]) == words.length
    words[word] = _.reduce sentences, (memo, sentence)->
      memo + _.count(sentence, word)
    , 0
  console.error "load #{_.size(words)} words"

  #全语料总长度
  total_length = _.reduce sentences, (memo, sentence)->
    memo + sentence.length
  , 0

  #作为基础词库，已有的词就不再列出了
  #词库取自sunpinyin
  sysdict = _.lines fs.readFileSync('sysdict.txt', encoding: 'utf8')
  console.error "load #{sysdict.length} system words"

  for word, count of words when count >= min_frequencies and word.length >= 2

    #去除已知词库中的词
    continue if word in sysdict

    #凝固度

    #候选词在语料中出现的概率
    p = count / total_length

    #候选词的组成部分在语料中出现的概率
    p_combined = Math.max.apply this, (for combination in combinations word
      _.reduce combination, (memo, part)->
        memo * words[part] / total_length
      , 1)

    cohesion = p / p_combined
    continue if cohesion < min_cohesion

    #自由度

    #左邻字信息熵
    neibors = {}
    for sentence in sentences
      parts = sentence.split word
      parts.pop()
      for part in parts
        neibor = part[part.length - 1]
        if neibors[neibor]
          neibors[neibor]++
        else
          neibors[neibor] = 1
    entropy = _.reduce neibors, (memo, c)->
      memo + -Math.log(c / count) / c
    , 0

    continue if entropy < min_entropy

    #右邻字信息熵
    neibors = {}
    for sentence in sentences
      parts = sentence.split word
      parts.shift()
      for part in parts
        neibor = part[0]
        if neibors[neibor]
          neibors[neibor]++
        else
          neibors[neibor] = 1
    entropy = _.reduce neibors, (memo, c)->
      memo + -Math.log(c / count) / c
    , 0

    continue if entropy < min_entropy

    console.log word, count #, cohesion, entropy

  console.error 'done'

else
  console.log 'Usage: node analyser.js files'