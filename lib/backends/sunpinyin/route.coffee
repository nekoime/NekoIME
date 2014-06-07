child_process = require 'child_process'
nekoime = require '../../nekoime'

express = require("express")
router = express.Router()
router.get "/logo.png", (req, res) ->
  res.sendfile("./lib/backends/sunpinyin/logo.png")

router.get "/config", (req, res) ->
  child_process.execFile 'fcitx-configtool'
  res.send 204

module.exports = router