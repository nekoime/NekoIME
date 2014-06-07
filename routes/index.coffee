nekoime = require '../lib/nekoime'

express = require("express")
router = express.Router()


# GET home page.
router.get "/", nekoime.login_check, (req, res) ->
  nekoime.db.words.find({}).sort({ frequencies: -1 }).limit(120).exec (err, docs)->
    return res.send err.toString() if err
    words = docs
    for word in words
      word.updated_at = "#{word.updated_at.getFullYear()}-#{word.updated_at.getMonth() + 1}-#{word.updated_at.getDate()} #{word.updated_at.getHours()}:#{word.updated_at.getMinutes()}:#{word.updated_at.getSeconds()}"

    nekoime.db.words.count {}, (err, count)->
      nekoime.db.user.findOne {}, (err, user)->
        return res.send err.toString() if err
        user_updated_at = new Date()
        res.render "index",
          words: words
          words_count: count
          user_name: user.profile.displayName
          user_image: user.profile.image.url + '&sz=200'
          user_updated_at: "#{user_updated_at.getFullYear()}-#{user_updated_at.getMonth() + 1}-#{user_updated_at.getDate()} #{user_updated_at.getHours()}:#{user_updated_at.getMinutes()}:#{user_updated_at.getSeconds()}"
          sources_count: nekoime.sources.length
          backend: nekoime.backend.id

module.exports = router