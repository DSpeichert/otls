Meteor.startup ->
  #Servers.getStatus 'shadowcores.twifysoft.net'
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
