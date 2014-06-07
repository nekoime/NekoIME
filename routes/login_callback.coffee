nekoime = require '../lib/nekoime'

express = require("express")
router = express.Router()


# GET home page.
router.get "/", (req, res) ->
  nekoime.db.user.update {}, {
    token: req.query.token
  }, {
    upsert: true
  }, (err, numReplaced, newDoc)->
    return res.send 500, err.toString() if err
    nekoime.update_profile (err)->
      return res.send 500, err.toString() if err
      res.redirect '/'

module.exports = router