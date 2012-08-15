http = require('http')

server = http.createServer (req, res) ->
  res.writeHead 200, {'Content-Type': 'text/plain'}
  res.end 'hello, i know nodejitsu\n'

server.listen(8080)