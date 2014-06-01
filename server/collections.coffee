Meteor.publish 'Servers', ->
  Servers.find()

Servers.allow
  insert: (userId, doc) ->
    if Servers.findOne {host: doc.host, port: doc.port}
      throw new Meteor.Error 409, 'Server is already listed.'

    try
      doc.createdAt = new Date()
      doc.userId = userId
      doc.status = Servers.getParsedStatus doc.host, doc.port
      doc.statusAt = new Date()
      doc.statusCount = 0
      doc.statusFail = 0
      doc.status.uptime = 0
      doc.satusHistory = []
    catch e
      console.log e.message
      return false

    true

  update: ->
    true

  remove: ->
    true
