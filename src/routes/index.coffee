SignedRequest = require 'facebook-signed-request'
async = require 'async'
Kinvey = require 'kinvey'

Kinvey.init
  appKey: process.env.KINVEY_APP_KEY
  masterSecret: process.env.KINVEY_MASTERSECRET

routes = (app) ->

  # handler for POST / route
  handleFacebookPOST = (req, res) ->
    #verify if Facebook Signed Request is present
    if !req.body['signed_request']
      throw new Error('no signed request in post')

    # Build array of task, which need to be executed by async
    tasks =
      parseSignedRequest: async.apply(parseSignedRequest, app, req)
      userLikesPage: ['parseSignedRequest', userLikesPage]
      userAuthorizedApp: ['parseSignedRequest', userAuthorizedApp]
      getKinveyUser: ['parseSignedRequest','userAuthorizedApp', getKinveyUser]

    # Run tasks
    async.auto tasks, (err, results ) ->
      if err
        console.error(err);
        res.send(500)
        return

      # results object:
      #  parseSignedRequest: parsed signed request from Facebook
      #  userLikesPage: boolean
      #  userAuthorizedApp: boolean
      #  getKinveyUser: user object from kinvey | null
      console.log results

      # Render view depending on the user liking the page or not
      if results.userLikesPage && !results.userAuthorizedApp
        oAuthDialogURL = createOAuthDialogURL(app, results.parseSignedRequest, 'email')
        res.render 'authorization',
          title: 'Simple Facebook Tab App'
          appID: app.get('FB App ID')
          userAuthorizedApp: results.userAuthorizedApp
          oAuthDialogURL: oAuthDialogURL
      else if results.userLikesPage && results.userAuthorizedApp
        res.render 'index',
          appID: app.get('FB App ID')
          kinveyUser: results.getKinveyUser.attr._socialIdentity
      else
        res.render 'fangate',
          appID: app.get('FB App ID')

  # POST / route
  app.post '/', handleFacebookPOST

  # GET / route TODO: remove this route; it is just for convenience, not needed for final app
  app.get '/', (req, res) ->
    res.render 'index',
      title: 'simple Facebook Tab App'
      appID: app.get('FB App ID')
      userAuthorizedApp: false
      oAuthDialogURL: ""

module.exports = routes

# parse the signed request from Facebook and add it to the results object
parseSignedRequest = (app, request, cb) ->
  SignedRequest.secret = app.get 'FB App Secret'
  signedRequest = new SignedRequest(request.body['signed_request'])
  signedRequest.parse (errors, req) ->
    return cb(errors) if errors.length
    cb null, req.data

# check if user likes page and add it to the results object as a boolean
userLikesPage = (cb, results) ->
  signedRequest =  results.parseSignedRequest
  cb new Error('no page object in signed request') unless signedRequest
  if signedRequest.page.liked
    cb null, true
  else
    cb null, false

# check if user has authorized app and add it to the results object as a boolean
userAuthorizedApp = (cb, results) ->
  signedRequest =  results.parseSignedRequest
  if signedRequest.user_id
    cb null, true
  else
    cb null, false

# helper function to build the url to the Facebook authorization screen
createOAuthDialogURL = (app, dataOfSignedRequest, scope) ->
  appID = app.get 'FB App ID'
  pageID = dataOfSignedRequest.page.id
  url = "https://www.facebook.com/dialog/oauth/
    ?client_id=#{appID}
    &redirect_uri=https%3A%2F%2Fwww.facebook.com%2Fpages%2Fnull%2F#{pageID}%3Fsk%3Dapp_#{appID}
    &scope=#{scope}"

# If user has authorized app the Facebook ID of the user is saved in the Kinvey User Collection
getKinveyUser = (cb, results) ->
  signedRequest =  results.parseSignedRequest
  if results.userAuthorizedApp
    # Fetch current user or create new user
    currentFacebookUser = new Kinvey.User();
    token = signedRequest.oauth_token;
    attr = {}
    currentFacebookUser.loginWithFacebook(token, attr,
      success: (user, info) ->
        cb null, user
      error: (error)->
        console.log 'error loginWithFacebook', error, info
        cb error
    )
  else
    cb null, null
