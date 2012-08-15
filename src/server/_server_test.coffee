server = require("./server.coffee")

exports.test_FirstTest = (test) ->
  test.ok(true, 'This assertion should pass')
  test.done()