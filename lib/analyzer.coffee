@analyze = (db, text, type, weight, callback)->
  callback [{word: text.replace(/[`~!@#$^&*()=|{}':;',\[\].<>/?~！@#￥……&*（）&;|{}【】‘；：”“'。，、？]/g, ''), weight: weight}], []


