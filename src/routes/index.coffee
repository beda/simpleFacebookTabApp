SignedRequest = require 'facebook-signed-request'
async = require 'async'

routes = (app) ->

  # determine page like
  userLikesPage = (req, cb) ->
    SignedRequest.secret = app.get 'FB App Secret'
    signedRequest = new SignedRequest(req.body['signed_request'])
    signedRequest.parse (errors, req) ->
      cb(errors) if errors.length
      if req.data.page.liked
        cb(null, true)
      else
        cb(null, false)

  # handler for POST / route
  handleFBPost = (req, res) ->
    if !req.body['signed_request']
      throw new Error('no signed request in post')

    tasks = {userLikesPage: async.apply(userLikesPage, req)}

    async.series tasks, (err,results) ->
      if err
        console.error(err.stack);
        res.send(500)
        return

      if results.userLikesPage
        res.render 'index',
          title: 'simple Facebook Tab App'
          appID: app.get('FB App ID')
      else
        res.render 'index',
          title: 'Fangate'
          appID: app.get('FB App ID')

  # POST / route
  app.post '/', handleFBPost

  # GET / route
  app.get '/', (req, res) ->
    res.render 'index',
      title: 'simple Facebook Tab App'
      appID: app.get('FB App ID')

module.exports = routes


