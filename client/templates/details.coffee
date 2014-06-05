Template.details.events
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
      else
        new PNotify
          title: 'All fine!'
          text: 'Refresh successful.'
          type: 'success'

Template.details.rendered = ->
  $('[data-toggle="tooltip"').tooltip()

  $('#fb-link').attr 'href', 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(Meteor.absoluteUrl Router.current().path)
  $('#fb-link').popupWindow
    height: 600
    width: 500
    top: 50
    left: 50
    menubar: false
    scrollbars: false
    toolbar: false

  Template.details.pingGague = Gauge document.getElementById('ping-gauge'),
    clazz: 'small'
    size :  100
    min  :  0
    max  :  200
    transitionDuration : 500

    label                      :  'Ping'
    minorTicks                 :  4
    majorTicks                 :  5
    needleWidthRatio           :  0.6
    needleContainerRadiusRatio :  0.7

    zones: [
      { clazz: 'yellow-zone', from: 0.50, to: 0.75 }
      { clazz: 'red-zone', from: 0.75, to: 1.0 }
    ]

  Template.details.pingGague.write Router.current().data().status.ping

  data =
    key: 'Players online'
    values: Router.current().data().statusHistory

  nv.addGraph ->
    chart = nv.models.stackedAreaChart()
      .margin({right: 60})
      .x (d) ->
        try
          return d.timestamp #We can modify the data accessor functions...
        catch e
          new Date()
      .y (d) ->
        try
          return d.players.online #...in case your data is formatted differently.
        catch e
          0
      .useInteractiveGuideline(true)    #Tooltips which show all data points. Very nice!
      .rightAlignYAxis(false)      #Let's move the y-axis to the right side.
      .transitionDuration(1000)
      .showControls(false)   #Allow user to choose 'Stacked', 'Stream', 'Expanded' mode.
      .clipEdge(true)
      .showLegend(false)

    #Format x-axis labels with custom function.
    chart.xAxis
      .tickFormat (d) ->
        moment(d).format('lll');

    chart.yAxis
      .tickFormat d3.format(' .0f')

    d3.select('#players-chart')
      .datum([data])
      .transition()
      .call(chart)

    nv.utils.windowResize chart.update
    chart


Template.detailsDescription.rendered = ->
  converter1 = Markdown.getSanitizingConverter()
  editor1 = new Markdown.Editor converter1
  editor1.run()

Template.detailsDescription.events
  'click #edit-description': (event) ->
    event.preventDefault()
    $('#description-editor').toggle()

  'change #wmd-input': (event) ->
    Servers.update
      _id: Session.get 'server'
    ,
      $set:
        description: event.currentTarget.value
