express = require("express")
path = require("path")
favicon = require("static-favicon")
logger = require("morgan")
cookieParser = require("cookie-parser")
app = express()

# view engine setup
app.set "views", path.join(__dirname, "views")
app.set "view engine", "html.mustache"
app.set 'layout', 'layout'       # use layout.html as the default layout
app.enable 'view cache'
app.engine 'html.mustache', require('hogan-express')

app.use favicon()
app.use logger("dev")
app.use require("body-parser")()
app.use cookieParser()
app.use require("stylus").middleware(path.join(__dirname, "public"))
app.use express.static(path.join(__dirname, "public"))

nekoime = require './lib/nekoime'

app.use "/", require "./routes/index"
app.use "/profile", require "./routes/profile"
#app.use "/backends", require "./routes/backends"
app.use "/words", require "./routes/words"
app.use "/sources", require "./routes/sources"
app.use "/login_callback", require "./routes/login_callback"

for source in nekoime.sources
  app.use '/sources/' + source.id, require './lib/sources/' + source.id + '/route' if source.route
for id, backend of nekoime.backends
  app.use '/backends/' + backend.id, require './lib/backends/' + backend.id + '/route' if backend.route

#/ catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error("Not Found")
  err.status = 404
  next err
  return


#/ error handlers

# development error handler
# will print stacktrace
if app.get("env") is "development"
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render "error",
      message: err.message
      error: err

    return


# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render "error",
    message: err.message
    error: {}

  return

module.exports = app