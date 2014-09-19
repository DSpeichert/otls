xml2js = Async.wrap Meteor.npmRequire('xml2js'), ['parseString']

net = Npm.require 'net'
Servers.getStatus = (host, port, callback) ->
  time = null
  client = net.connect
    host: host
    port: port, ->
      #console.log 'we connected to ' + client.remoteAddress + ':' + client.remotePort
      time = new Date()
      # this does not work: String.fromCharCode(6) + String.fromCharCode(0) + String.fromCharCode(255) + String.fromCharCode(255) + 'info'
      # We need to use buffer here because nodejs converts null (0x00) to space (0x20) in ASCII
      client.write new Buffer('0600ffff696e666f', 'hex')

  client.setTimeout 3000, ->
    #console.log 'remote timed out after reading ' + client.bytesRead + ' bytes and writing ' + client.bytesWritten + ' bytes'
    client.end()
    client.destroy()
    callback new Meteor.Error(504, 'Client timed out')

  client.setEncoding 'ascii'

  client.on 'data', (data) ->
    #console.log 'got some response', data
    ip = client.remoteAddress
    client.end()
    client.destroy()
    #console.log 'we disconnected after reading ' + client.bytesRead + ' bytes and writing ' + client.bytesWritten + ' bytes'
    callback null, [data, ip, new Date().getMilliseconds() - time.getMilliseconds()]

  client.on 'end', ->
    #console.log 'remote disconnected after reading ' + client.bytesRead + ' bytes and writing ' + client.bytesWritten + ' bytes'
    # even though we return false here, the caller gets "undefined"
    # if we pass null as return value, exception is thrown
    callback new Meteor.Error(420, 'Server throttled connection')

  client.on 'error', ->
    time = null
    host = host
    port = port
    callback = callback
    client = net.connect
      host: host
      port: port, ->
        #console.log 'we connected to ' + client.remoteAddress + ':' + client.remotePort
        time = new Date()
        # this does not work: String.fromCharCode(6) + String.fromCharCode(0) + String.fromCharCode(255) + String.fromCharCode(255) + 'info'
        # We need to use buffer here because nodejs converts null (0x00) to space (0x20) in ASCII
        client.write new Buffer('0600ffff696e666f', 'hex')

    client.setTimeout 3000, ->
      #console.log 'remote timed out after reading ' + client.bytesRead + ' bytes and writing ' + client.bytesWritten + ' bytes'
      client.end()
      client.destroy()
      callback new Meteor.Error(504, 'Client timed out')

    client.setEncoding 'ascii'

    client.on 'data', (data) ->
      #console.log 'got some response', data
      ip = client.remoteAddress
      client.end()
      client.destroy()
      #console.log 'we disconnected after reading ' + client.bytesRead + ' bytes and writing ' + client.bytesWritten + ' bytes'
      callback null, [data, ip, new Date().getMilliseconds() - time.getMilliseconds()]

    client.on 'end', ->
      #console.log 'remote disconnected after reading ' + client.bytesRead + ' bytes and writing ' + client.bytesWritten + ' bytes'
      # even though we return false here, the caller gets "undefined"
      # if we pass null as return value, exception is thrown
      callback new Meteor.Error(420, 'Server throttled connection')

    client.on 'error', ->
      callback new Meteor.Error(504, 'Client had socket error')

Servers.getParsedStatus = (host, port, callback) ->
  Servers.getStatus host, port, Meteor.bindEnvironment (error, result) ->
    if error
      callback error
      return

    [raw_status, remoteAddress, ping] = result
    status = xml2js.parseString raw_status

    try
      ip_whois = HTTP.get('http://ip-api.com/json/' + remoteAddress).data

    try
    # close your eyes, this is lame
      normalized_status =
        serverinfo:
          ip: status.tsqp.serverinfo[0].$.ip
          port: parseInt status.tsqp.serverinfo[0].$.port
          servername: status.tsqp.serverinfo[0].$.servername
          uptime: parseInt status.tsqp.serverinfo[0].$.uptime
          location: status.tsqp.serverinfo[0].$.location
          url: status.tsqp.serverinfo[0].$.url
          server: status.tsqp.serverinfo[0].$.server
          version: status.tsqp.serverinfo[0].$.version
          client: status.tsqp.serverinfo[0].$.client
        owner:
          name: status.tsqp.owner[0].$.name
          email: status.tsqp.owner[0].$.email
        players:
          online: parseInt status.tsqp.players[0].$.online
          max: parseInt status.tsqp.players[0].$.max
          peak: parseInt status.tsqp.players[0].$.peak
        map:
          name: status.tsqp.map[0].$.name
          author: status.tsqp.map[0].$.author
          width: parseInt status.tsqp.map[0].$.width
          height: parseInt status.tsqp.map[0].$.height
        motd: status.tsqp.motd[0]
        ip: remoteAddress
        ip_whois: ip_whois
        ping: ping
        online: true

      # monsters & npcs are optional
      normalized_status.monsters = {total: status.tsqp.monsters[0].$.total} if status.tsqp.monters?
      normalized_status.npcs = {total: status.tsqp.npcs[0].$.total} if status.tsqp.npcs?
      # some servers report rates
      if status.tsqp.rates
        normalized_status.rates =
          experience: status.tsqp.rates[0].$.experience
          magic: status.tsqp.rates[0].$.magic
          skill: status.tsqp.rates[0].$.skill
          loot: status.tsqp.rates[0].$.loot
          spawn: status.tsqp.rates[0].$.spawn

    catch e
      callback Meteor.Error(406, 'Malformed status ' + e.message, JSON.stringify status)
      return

    try
      HTTP.get 'https://spigu.net/api/otshosting/' + normalized_status.ip # this will throw 403
    catch e
      spigu_info = e.message

    normalized_status.spigu_hosting = /not authorized/.test spigu_info
    try
      normalized_status.ddos_protected = /^(Hosteam)/i.test(normalized_status.ip_whois.isp) or normalized_status.spigu_hosting

    callback null, normalized_status

Servers.getParsedStatusSync = Async.wrap Servers.getParsedStatus

Servers.refresh = (id) ->
  server = Servers.findOne
    _id: id

  throw new Meteor.Error 500, 'Server not found' if not server?

  try
    status = @getParsedStatusSync server.host, server.port
  catch e
    if e.error == 420
      throw new Meteor.Error 420, 'Server did not return any data'

    Servers.update
      _id: id,
        $set:
          'status.online': false
          'status.uptime': 100 - (server.statusFail+1)/(server.statusCount+1)*100
        $inc:
          statusCount: 1
          statusFail: 1

    return status

  status.uptime = 100 - (server.statusFail)/(server.statusCount+1)*100
  status.online = true

  Servers.update _id: id,
    $set:
      status: status
      statusAt: new Date()
    $inc:
      statusCount: 1

  if server.status
    StatusHistory.insert _.extend server.status,
        serverId: server._id
        timestamp: server.statusAt

  status

Servers.getStatusInfoPlayers = (host, port, callback) ->
  time = null
  client = net.connect
    host: host
    port: port, ->
      #console.log 'we connected to ' + client.remoteAddress + ':' + client.remotePort
      time = new Date()
      client.write new Buffer '0600ff0120000000', 'hex'

  client.setTimeout 2000, ->
    #console.log 'remote timed out after reading ' + client.bytesRead + ' bytes and writing ' + client.bytesWritten + ' bytes'
    client.end()
    client.destroy()
    callback? new Meteor.Error(504, 'Client timed out')

  bufs = []
  client.on 'data', (data) ->
    bufs.push(data)

  client.on 'end', ->
    #console.log 'remote disconnected after reading ' + client.bytesRead + ' bytes and writing ' + client.bytesWritten + ' bytes'
    data = Buffer.concat bufs

    if data.length == 0
      callback? new Meteor.Error(503, 'No data returned')
      return

    if data[2] != 33
      console.log 'malformed data: not a player list', data
      callback? new Meteor.Error(504, 'malformed data: not a player list')
      return

    players_online = data.readUInt32LE 3
    #console.log 'players online: ' + players_online
    pos = 7
    i = 0
    players = []
    while i < players_online
      nameLen = data.readUInt16LE pos
      pos += 2
      name = data.toString 'utf8', pos, pos + nameLen
      pos += nameLen
      level = data.readUInt32LE pos
      pos += 4
      players.push
        name: name
        level: level
      ++i

    callback? null, [players, new Date().getMilliseconds() - time.getMilliseconds()]

  client.on 'error', ->
    console.log 'socket error'
    callback? new Meteor.Error(504, 'socket error')

# This function is currently not used
Servers.refreshPlayers = (id) ->
  server = Servers.findOne
    _id: id

  throw new Meteor.Error 500, 'Server not found' if not server?

  try
    [players, ping] = @getStatusInfoPlayersSync server.host, server.port
  catch e
    return players

  return players if players is null

  Servers.update _id: id,
    $set:
      players: players
      playersAt: new Date()

  players
