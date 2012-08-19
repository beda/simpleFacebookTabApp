SignedRequest = require 'facebook-signed-request'
async = require 'async'
Kinvey = require 'kinvey'

Kinvey.init
  appKey: process.env.KINVEY_APP_KEY
  #appSecret: process.env.KINVEY_APPSECRET
  masterSecret: process.env.KINVEY_MASTERSECRET

routes = (app) ->

  # handler for POST / route
  handleFacebookPOST = (req, res) ->
    if !req.body['signed_request']
      throw new Error('no signed request in post')

    tasks =
      parseSignedRequest: async.apply(parseSignedRequest, app, req)
      #userLikesPage: userLikesPage
      #userAuthorizedApp: userAuthorizedApp

    async.auto tasks, (err, result ) ->
      console.log err, result
      #console.log 'userLike', userLikesPage, 'userAuth', userAuthorizedApp , 'data', dataOfSignedRequest

      ###
      if err
        console.error(err.stack);
        res.send(500)
        return

      oAuthDialogURL = createOAuthDialogURL(app, dataOfSignedRequest, 'email')

      if userAuthorizedApp
        getKinveyUser dataOfSignedRequest, (error, user)->
          console.log error, user

      if userLikesPage
        res.render 'index',
          title: 'simple Facebook Tab App'
          appID: app.get('FB App ID')
          userAuthorizedApp: userAuthorizedApp
          oAuthDialogURL: oAuthDialogURL
      else
        res.render 'index',
          title: 'Fangate'
          appID: app.get('FB App ID')
          userAuthorizedApp: userAuthorizedApp
          oAuthDialogURL: oAuthDialogURL
      ###

  # POST / route
  app.post '/', handleFacebookPOST

  # GET / route
  app.get '/', (req, res) ->
    res.render 'index',
      title: 'simple Facebook Tab App'
      appID: app.get('FB App ID')

module.exports = routes

parseSignedRequest = (app, request, cb) ->
  SignedRequest.secret = app.get 'FB App Secret'
  signedRequest = new SignedRequest(request.body['signed_request'])
  signedRequest.parse (errors, req) ->
    return cb(errors) if errors.length
    cb null, req.data

# determine page like
userLikesPage = (dataOfSignedRequest, cb) ->
  callback new Error('no page object in signed request') unless dataOfSignedRequest.page
  if dataOfSignedRequest.page.liked
    cb null, true, dataOfSignedRequest
  else
    cb null, false, dataOfSignedRequest

userAuthorizedApp = (pageLike, dataOfSignedRequest, cb) ->
  if dataOfSignedRequest.user_id
    cb(null, true, pageLike, dataOfSignedRequest)
  else
    cb(null, false, pageLike, dataOfSignedRequest)

createOAuthDialogURL = (app, dataOfSignedRequest, scope) ->
  appID = app.get 'FB App ID'
  pageID = dataOfSignedRequest.page.id
  url = "https://www.facebook.com/dialog/oauth/
    ?client_id=#{appID}
    &redirect_uri=https%3A%2F%2Fwww.facebook.com%2Fpages%2Fnull%2F#{pageID}%3Fsk%3Dapp_#{appID}
    &scope=#{scope}"

getKinveyUser = (dataOfSignedRequest, cb) ->
  query = new Kinvey.Query()
  query.on('username').equal dataOfSignedRequest.user_id
  userCollection = new Kinvey.UserCollection({ query: query })
  userCollection.fetch
    success: (user) ->
      cb null, user,
    error: (error)->
      cb error
