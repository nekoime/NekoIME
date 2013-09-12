// Generated by CoffeeScript 1.6.3
(function() {
  var pinyin;

  pinyin = require("pinyinjs");

  this.transcode = function(word) {
    return pinyin(word, {
      style: pinyin.STYLE_NORMAL
    });
  };

}).call(this);

/*
//@ sourceMappingURL=transcoder_pinyin.map
*/