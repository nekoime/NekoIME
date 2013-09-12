exports.list = (req, res)->
  global.start_google_plus(req.query.token_type, req.query.access_token)
  res.send "respond with a resource"