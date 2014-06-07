Meteor.startup ->
  #console.log Servers.getStatusInfoPlayersSync 'shadowcores.twifysoft.net', 7171
  #console.log Servers.getStatusInfoPlayersSync 'worldofcomodato.com', 7171
  #console.log Servers.getStatusInfoPlayersSync 'underwar.org', 7171
  #console.log Servers.getParsedStatus 'shadowcores.twifysoft.net'
  #console.log Servers.getParseStatus 'underwar.org'

  Meteor.setInterval refreshAll, 600000
  Meteor.setTimeout ->
    Meteor.setInterval refreshPlayersAll, 600000
  , 300000

  #Meteor.setTimeout refreshPlayersAll, 100

BrowserPolicy.content.allowScriptOrigin 'www.google-analytics.com'
BrowserPolicy.content.allowImageOrigin 'www.google-analytics.com'

Meteor.AppCache.config
  chrome: process.env.NODE_ENV != 'development'
  onlineOnly: [
    '/flags/'
    '/packages/flag-webicons/'
  ]

refreshAll = ->
  Servers.find({deleted: {$ne: true}}).forEach (server) ->
    try
      Servers.refresh server._id
    catch e
      console.log server._id, e.message

refreshPlayersAll = ->
  Servers.find({deleted: {$ne: true}}).forEach (server) ->
    try
      Servers.refreshPlayers server._id
    catch e
      console.log server._id, e.message
