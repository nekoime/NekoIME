express = require("express")
router = express.Router()
nekoime = require '../lib/nekoime'

router.get "/", nekoime.login_check, (req, res) ->
  nekoime.db.user.findOne {}, (err, user)->
    return res.send err.toString() if err
    user_updated_at = new Date()
    res.render "profile",
      user_name: user.profile.displayName
      user_image: user.profile.image.url + '&sz=64'
      user_updated_at: "#{user_updated_at.getFullYear()}-#{user_updated_at.getMonth() + 1}-#{user_updated_at.getDate()} #{user_updated_at.getHours()}:#{user_updated_at.getMinutes()}:#{user_updated_at.getSeconds()}"

module.exports = router