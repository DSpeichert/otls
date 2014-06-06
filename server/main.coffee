Meteor.startup ->
  #console.log Servers.getStatusInfoSync 'shadowcores.twifysoft.net', 7171
  #Servers.getStatus 'underwar.org'

  Meteor.setInterval ->
    Servers.find({deleted: {$ne: true}}).forEach (server) ->
      try
        Servers.refresh server._id
      catch e
        console.log server._id, e.message
  , 300000

BrowserPolicy.content.allowScriptOrigin 'www.google-analytics.com'
BrowserPolicy.content.allowImageOrigin 'www.google-analytics.com'

Meteor.AppCache.config
  chrome: process.env.NODE_ENV != 'development'
  onlineOnly: [
    '/flags/'
    '/packages/flag-webicons/'
  ]
