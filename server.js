'use strict'

const http = require('http')

const server = http.createServer()

server
  .on('error', console.error)
  .on('request', (req, resp) => {
    resp.end(
      'This is a demo server that ships with `tls-refresh`\n\n' +
      'Check out the project >> https://github.com/zbo14/tls-refresh'
    )
  })
  .listen(9000, '0.0.0.0', () => {
    console.log('HTTP server listening on port 9000')
  })
