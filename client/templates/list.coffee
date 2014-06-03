Template.listMenu.events
  'click #refresh-client-chart': ->
    Template.listMenu.drawClientChart()

Template.listMenu.servers_count = ->
  Servers.find
    'status.online': true
  .count()

Template.listMenu.servers_ddos_count = ->
  Servers.find
    'status.online': true
    'status.ddos_protected': true
  .count()

Template.listMenu.servers_spigu_count = ->
  Servers.find
    'status.online': true
    'status.spigu_hosting': true
  .count()

Template.listMenu.servers_offline_count = ->
  Servers.find
    'status.online': false
  .count()

Template.listMenu.isCurrentTag = (tag) ->
  if tag == Router.current().params.tag or (tag == 'all' and Router.current().route.name == 'list')
    'active'
  else
    false

Template.listMenu.drawClientChart = ->
  clientData = _.chain Servers.find({
    'status.online': true
  }).fetch()
  .countBy (el) ->
      try
        return el.status.serverinfo.client
      catch e
        return 'unknown'
  .map (value, key) ->
      version: key
      count: value
  .sortBy (value) ->
      value.count
  .value()

  $('#client-chart').html()
  nv.addGraph ->
    chart = nv.models.pieChart()
    .x (d) ->
        return d.version
    .y (d) ->
        return d.count
    .showLabels(true)
    .showLegend(false)

    d3.select("#client-chart")
    .datum(clientData)
    .transition().duration(1200)
    .call(chart)

    chart

Template.listMenu.rendered = ->
  sub = Meteor.subscribe 'Servers', ->
    Template.listMenu.drawClientChart()
    sub.stop()
    #$('#refresh-client-chart').show()

Template.list.playersOnlineServers = Template.listMenu.servers_count

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