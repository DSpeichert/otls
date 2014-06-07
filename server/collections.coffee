Meteor.publish 'Servers', (scope) ->
  check scope, Match.Optional [String]
  if _.indexOf(scope, 'players') != -1
    Servers.find()
  else
    Servers.find {},
      fields:
        players: 0

Meteor.publish 'StatusHistory', (scope) ->
  check scope,
    serverId: String

  StatusHistory.find
    serverId: scope.serverId
    timestamp:
      $gt: moment().subtract('days', 1).toDate()
  ,
    fields:
      serverId: 1
      timestamp: 1
      'players.online': 1

Servers.allow
  insert: (userId, doc) ->
    if Servers.findOne {host: doc.host, port: doc.port}
      throw new Meteor.Error 409, 'Server is already listed.'

    try
      doc.createdAt = new Date()
      doc.userId = userId
      doc.status = Servers.getParsedStatusSync doc.host, doc.port
      doc.statusAt = new Date()
      doc.statusCount = 1
      doc.statusFail = 0
      doc.status.uptime = 100
    catch e
      throw new Meteor.Error 400, 'Cannot get server status.'

    true

  update: ->
    true

  remove: ->
    true
