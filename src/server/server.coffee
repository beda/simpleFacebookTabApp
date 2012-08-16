express = require('express')
app = express()
SignedRequest = require 'facebook-signed-request'

# Configuration
if ('development' == app.get('env'))
  app.set 'FB App ID', process.env.LOCAL_FACEBOOK_APP_ID
  app.set 'FB App Secret', process.env.LOCAL_FACEBOOK_SECRET
  SignedRequest.secret = app.get 'FB App Secret'
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

if ('production' == app.get('env'))
  app.set 'FB App ID', process.env.FACEBOOK_APP_ID
  app.set 'FB App Secret', process.env.FACEBOOK_SECRET
  app.use express.errorHandler()

app.configure ->
  app.set 'port', 8080
  app.set 'views', __dirname + '/../../views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use app.router
  app.use express.static(__dirname + '/public')

#Routes
app.get '/', (req, res) ->
  res.render 'index',
    title: 'simple Facebook Tab App'
    appID: app.get('FB App ID')

app.post '/', (req, res) ->
  if req.body['signed_request']
    signedRequest = new SignedRequest(req.body['signed_request'])
    signedRequest.parse (error, req) ->
      res.render 'index',
        title: 'simple Facebook Tab App'
        appID: app.get('FB App ID')
  else
    res.send 'error'

app.listen(app.get('port'))
console.log("Express server listening on port 8080 in %s mode", app.settings.env);