SignedRequest = require 'facebook-signed-request'
async = require 'async'

routes = (app) ->
  SignedRequest.secret = app.get 'FB App Secret'

  # check if signed request ist present and determine page like
  CheckIfUserLikesPage = (req, callback) ->
    if req.body['signed_request']
      signedRequest = new SignedRequest(req.body['signed_request'])
      signedRequest.parse (errors, req) ->
        if errors.length
          callback errors
        if req.data.page.liked
          callback null, true
        else
          callback null, false
    else
      callback(new Error('no signed request in post'));

  # handler for POST / route
  handleFBPost = (req, res) ->
    tasks = [async.apply(CheckIfUserLikesPage, req)]

    async.series tasks, (err,results) ->
      if err
        console.log err
        return res.send('error')

      userLikesPage = results[0]

      if userLikesPage
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


