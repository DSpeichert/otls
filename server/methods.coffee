Meteor.methods
  refresh: (id) ->
    check id, String
    Servers.refresh id

  importFromShit: (n=1) ->
    check n, Number
    site = HTTP.get 'http://otservlist.org/list-server_players_online-desc-' + n + '.html'
    regexp = /\<a href="\/ots\/[0-9]+"\>([^<]+)\<\/a\>/gi
    while match = regexp.exec site.content
      if Servers.findOne {host: match[1], port: 7171}
        console.log 'Import: skipping ' + match[1]
        continue

      try
        status = Servers.getParsedStatusSync match[1], 7171
        if status is false
          throw new Meteor.Error 420, 'Server did not return any data'
        status.uptime = 100
        id = Servers.insert
          host: match[1]
          port: 7171
          createdAt: new Date()
          lastCheck: new Date()
          status: status
          statusAt: new Date()
          statusCount: 0
          statusFail: 0

        console.log 'Import: added ' + match[1] + ' as ' + id
      catch e
        console.log e.message, e.details
