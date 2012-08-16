SignedRequest = require 'facebook-signed-request'

routes = (app) ->
  SignedRequest.secret = app.get 'FB App Secret'
  app.get '/', (req, res) ->
    res.render 'index',
      title: 'simple Facebook Tab App'
      appID: app.get('FB App ID')

  app.post '/', (req, res) ->
    if req.body['signed_request']
      signedRequest = new SignedRequest(req.body['signed_request'])
      signedRequest.parse (errors, req) ->
        if errors.length
          return res.send('error')
        if req.data.page.liked
          res.render 'index',
            title: 'simple Facebook Tab App'
            appID: app.get('FB App ID')
        else
          res.render 'index',
            title: 'Fangate'
            appID: app.get('FB App ID')
    else
      res.send 'error'

module.exports = routes