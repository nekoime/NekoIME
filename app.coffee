# Module dependencies.
express = require("express")
routes = require("./routes")
user = require("./routes/user")
google_plus = require("./routes/google_plus")
http = require("http")
path = require("path")
app = express()

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use require("less-middleware")(src: __dirname + "/public")
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")
app.get "/", routes.index
app.get "/users", user.list
app.get "/google_plus", google_plus.list
http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")

request = require 'request'
global.start_google_plus = (token_type, access_token)->
  console.log(token_type, access_token)
  request
    url: "https://www.googleapis.com/plus/v1/people/me/people/visible"
    header:
      authorization: "#{token_type} #{access_token}"
      origin: "http://localhost:3000"
  , (err, body)->
      console.log body

