request = require 'request'
#mongo = require('mongodb')

@start = (callback)->
  request
    url:'http://zh.moegirl.org/api.php?action=query&list=allpages&apnamespace=0&aplimit=500&apfrom=一&format=json'
    json: true
  ,(error, response, body)->
      throw error if error
      for page in body.query.allpages
        callback('moegirlwiki', page.title, 'title', 1)

