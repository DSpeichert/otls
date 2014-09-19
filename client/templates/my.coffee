Template.list.playersOnlineServers = Template.listMenu.servers_count
Template.list.meteor_status = Meteor.status

Template.list.playersOnline = ->
  _.reduce Servers.find({
      'status.online': true
    }).fetch(), (memo, server) ->
      try
        memo + server.status.players.online
      catch e
        return memo
    , 0

Session.setDefault 'search-term', ''

Template.list.servers = ->
  query =
    'status.serverinfo.servername':
      $regex: Session.get 'search-term'
      $options: 'i'
    'status.online': Router.current().params.tag != 'offline'

  if Router.current().params.tag == 'v10+'
    query['status.serverinfo.client'] =
      $regex: '^1([0-9])\.'
      $options: 'i'
  query['status.spigu_hosting'] = true if Router.current().params.tag == 'spigu'
  query['status.ddos_protected'] = true if Router.current().params.tag == 'ddos'

  try
    Servers.find query,
      sort:
        'status.players.online': -1
    .fetch()
  catch e
    console.log e.message

Template.list.events
  'click button[data-action="remove"]': (event) ->
    event.preventDefault()
    Servers.remove
      _id: event.currentTarget.dataset.id

  'click button[data-action="refresh"]': (event) ->
    event.preventDefault()
    Meteor.call 'refresh', event.currentTarget.dataset.id, (error, result) ->
      if error
        new PNotify
          title: 'Oh No!'
          text: error.message
          type: 'error'
          delay: 2000
          animation: 'fade'
      else
        new PNotify
          title: 'All fine!'
          text: 'Refresh successful.'
          type: 'success'
          delay: 2000
          animation: 'fade'

