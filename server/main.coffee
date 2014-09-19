Meteor.startup ->
  #console.log Servers.getStatusInfoPlayersSync 'shadowcores.twifysoft.net', 7171
  #console.log Servers.getStatusInfoPlayersSync 'worldofcomodato.com', 7171
  #console.log Servers.getStatusInfoPlayersSync 'underwar.org', 7171
  #console.log Servers.getParsedStatusSync 'shadowcores.twifysoft.net', 7171
  #console.log Servers.getParseStatus 'underwar.org', 7171

  Meteor.setInterval refreshAll, 10000
  Meteor.setInterval removeDead, 3600000
  removeDead()
  #Meteor.setTimeout ->
  #  Meteor.setInterval(refreshPlayersAll, 600000)
  #, 300000

  #refreshPlayersAll()
  #Meteor.setTimeout ->
  #  refreshAll()
  #, 100

BrowserPolicy.content.allowScriptOrigin 'www.google-analytics.com'
BrowserPolicy.content.allowImageOrigin 'www.google-analytics.com'

Meteor.AppCache.config
  chrome: process.env.NODE_ENV != 'development'
  onlineOnly: [
    '/flags/'
    '/packages/gadicohen_flag-webicons/'
  ]

refreshAll = ->
  Servers.find({deleted: {$ne: true}, lastCheck: {$lt: moment().subtract(70, 'seconds').toDate()}},
  {limit: 10, sort: ['lastCheck']}).forEach (server) ->
    console.log 'Refreshing server', server.host, ':', server.port
    Servers.update
      _id: server._id,
        $set:
          lastCheck: new Date()
    Servers.getParsedStatus server.host, server.port, Meteor.bindEnvironment (error, status) ->
      if error
        console.log '[cron] error checking status server', server._id, error.message
        return if error.error == 420
        Servers.update
          _id: server._id,
            $set:
              'status.online': false
              'status.uptime': 100 - (server.statusFail+1)/(server.statusCount+1)*100
            $inc:
              statusCount: 1
              statusFail: 1
        return

      status.uptime = 100 - (server.statusFail)/(server.statusCount+1)*100
      status.online = true

      Servers.update _id: server._id,
        $set:
          status: status
          statusAt: new Date()
        $inc:
          statusCount: 1

      if server.status
        StatusHistory.insert _.extend server.status,
          serverId: server._id
          timestamp: server.statusAt

refreshPlayersAll = ->
  Servers.find({deleted: {$ne: true}, online: true}).forEach (server) ->
    Servers.getStatusInfoPlayers server.host, server.port, Meteor.bindEnvironment (error, result) ->
      if error
        return console.log '[cron] error checking players list on server', server._id, error.message

      [players, ping] = result

      Servers.update _id: server._id,
        $set:
          players: players
          playersAt: new Date()

removeDead = ->
  console.log 'Removing dead'
  Servers.update
    deleted: {$ne: true}
    lastCheck: {$gt: moment().subtract(1, 'days').toDate()}
    statusAt: {$lt: moment().subtract(7, 'days').toDate()}
  ,
    $set:
      deleted: true
  ,
    multi: true
