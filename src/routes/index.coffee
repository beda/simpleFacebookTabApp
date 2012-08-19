SignedRequest = require 'facebook-signed-request'
async = require 'async'
Kinvey = require 'kinvey'

Kinvey.init
  appKey: process.env.KINVEY_APP_KEY
  masterSecret: process.env.KINVEY_MASTERSECRET

routes = (app) ->

  # handler for POST / route
  handleFacebookPOST = (req, res) ->
    if !req.body['signed_request']
      throw new Error('no signed request in post')

    tasks =
      parseSignedRequest: async.apply(parseSignedRequest, app, req)
      userLikesPage: ['parseSignedRequest', userLikesPage]
      userAuthorizedApp: ['parseSignedRequest', userAuthorizedApp]
      getKinveyUser: ['parseSignedRequest', getKinveyUser]

    async.auto tasks, (err, results ) ->
      if err
        console.error(err);
        res.send(500)
        return

      console.log results

      oAuthDialogURL = createOAuthDialogURL(app, results.parseSignedRequest, 'email')

      if userLikesPage
        res.render 'index',
          title: 'simple Facebook Tab App'
          appID: app.get('FB App ID')
          userAuthorizedApp: results.userAuthorizedApp
          oAuthDialogURL: oAuthDialogURL
      else
        res.render 'index',
          title: 'Fangate'
          appID: app.get('FB App ID')
          userAuthorizedApp: results.userAuthorizedApp
          oAuthDialogURL: oAuthDialogURL

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

userLikesPage = (cb, results) ->
  signedRequest =  results.parseSignedRequest
  cb new Error('no page object in signed request') unless signedRequest
  if signedRequest.page.liked
    cb null, true
  else
    cb null, false

userAuthorizedApp = (cb, results) ->
  signedRequest =  results.parseSignedRequest
  if signedRequest.user_id
    cb null, true
  else
    cb null, false

createOAuthDialogURL = (app, dataOfSignedRequest, scope) ->
  appID = app.get 'FB App ID'
  pageID = dataOfSignedRequest.page.id
  url = "https://www.facebook.com/dialog/oauth/
    ?client_id=#{appID}
    &redirect_uri=https%3A%2F%2Fwww.facebook.com%2Fpages%2Fnull%2F#{pageID}%3Fsk%3Dapp_#{appID}
    &scope=#{scope}"

getKinveyUser = (cb, results) ->
  signedRequest =  results.parseSignedRequest
  if results.userAuthorizedApp

    Kinvey.init
      appKey: process.env.KINVEY_APP_KEY
      masterSecret: process.env.KINVEY_MASTERSECRET
    query = new Kinvey.Query()
    query.on('username').equal signedRequest.user_id
    userCollection = new Kinvey.UserCollection({ query: query })

    userCollection.fetch(
      success: (list) ->
        if list.length
          user = list[0].attr
          cb null, user
        else
          Kinvey.init
            appKey: process.env.KINVEY_APP_KEY
            appSecret: process.env.KINVEY_APPSECRET
          Kinvey.User.create(
            {username: signedRequest.user_id},
            { success: (user)->
                console.log user
                cb null, user ,
              error: (error)->
                console.log 'create Error'
                cb error
            })
      error: (error)->
        console.log 'Collection fetch Error'

        cb error
    )

  else
    cb null, null
