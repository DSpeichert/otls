Meteor.methods
  refresh: (id) ->
    check id, String
    Servers.refresh id

  importFromShit: ->
    site = HTTP.get 'http://otservlist.org'
    regexp = /\<a href="\/ots\/[0-9]+"\>([^<]+)\<\/a\>/gi
    while match = regexp.exec site.content
      if Servers.findOne {host: match[1], port: 7171}
        console.log 'skipping ' + match[1]
        continue

      id = Servers.insert
        host: match[1]
        port: 7171
        createdAt: new Date()
        statusCount: 0
        statusFail: 0

      try
        Servers.refresh id
        console.log 'added ' + match[1] + ' as ' + id
      catch e
        console.log e.message, e.details
        Servers.remove
          _id: id
