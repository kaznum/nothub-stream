EventEmitter = require('events').EventEmitter
sio = require('socket.io')

class SocketIOListener extends EventEmitter
  constructor: (@port, @configure) ->

  listen: (server) ->
    @io = sio.listen(@port)
    @configure?(@io)
    self = this
    @io.sockets.on 'connection', (socket) ->
      socket.on 'ping', (data) ->
        socket.emit('pong', data)

      server.connect socket.id, null, (err, data) ->
        socket.emit('gh_event pushed', data)
      socket.on 'query', (query) ->
        self.emit('query-update', null, socket.id, query)
        server.updateSchema(socket.id, query)
      socket.on 'disconnect', ->
        server.disconnect(socket.id)

  close: () ->
    @io.server.close()

module.exports = SocketIOListener
