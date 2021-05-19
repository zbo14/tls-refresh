'use strict'

const http = require('http')

const server = http.createServer()

server
  .on('error', console.error)
  .on('request', (req, resp) => {
    resp.end(
      'This is a demo server for `tls-refresh`\n\n' +
      'Check it out at https://github.com/zbo14/tls-refresh'
    )
  })
  .listen(9000, '0.0.0.0', () => {
    console.log('HTTP server listening on port 9000')
  })
