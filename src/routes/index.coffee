SignedRequest = require 'facebook-signed-request'
async = require 'async'



routes = (app) ->
  SignedRequest.secret = app.get 'FB App Secret'
  app.get '/', (req, res) ->
    res.render 'index',
      title: 'simple Facebook Tab App'
      appID: app.get('FB App ID')

  handleFBPost = (req, res) ->
    CheckIfUserLikesPage = (callback) ->
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


    tasks = [CheckIfUserLikesPage]

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

  app.post '/', handleFBPost



module.exports = routes