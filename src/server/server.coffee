express = require('express')
app = express()

# Configuration
if ('development' == app.get('env'))
  app.set 'FB App ID', process.env.LOCAL_FACEBOOK_APP_ID
  app.set 'FB App Secret', process.env.LOCAL_FACEBOOK_SECRET
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

if ('production' == app.get('env'))
  app.set 'FB App ID', process.env.FACEBOOK_APP_ID
  app.set 'FB App Secret', process.env.FACEBOOK_SECRET
  app.use express.errorHandler()

app.configure ->
  app.set 'views', __dirname + '/../../views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use require('faceplate').middleware
    app_id: app.get 'FB App ID'
    secret: app.get 'FB App Secret'
    scope:  ''
  app.use app.router
  app.use express.static(__dirname + '/public')

#Routes
app.get '/', (req, res) ->
  res.render 'index', {title: 'simple Facebook Tab App'}

app.listen(8080)
console.log("Express server listening on port 8080 in %s mode", app.settings.env);