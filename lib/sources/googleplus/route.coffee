child_process = require 'child_process'
formidable = require 'formidable'
pinyin = require("pinyin");
nekoime = require '../../nekoime'

express = require("express")
router = express.Router()
router.get "/logo.png", (req, res) ->
  res.sendfile("./lib/sources/googleplus/logo.png")


module.exports = router