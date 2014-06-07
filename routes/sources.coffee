express = require("express")
router = express.Router()
nekoime = require '../lib/nekoime'
router.get "/", nekoime.login_check, (req, res) ->
  nekoime.db.words.find({}).exec (err, docs)->
    return res.send 500, err.toString() if err
    counts = {}
    for word in docs
      source = word.source.split(':',2)[0]
      if counts[source]
        counts[source]++
      else
        counts[source] = 1

    for source in nekoime.sources
      source.count = counts[source.id] ? 0

    res.render "sources",
      title: "Express"
      sources: nekoime.sources

module.exports = router