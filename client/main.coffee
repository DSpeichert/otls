Router.configure
  layoutTemplate:   'layout'
  notFoundTemplate: '404'
  loadingTemplate:  'loading'
#Router.onBeforeAction 'dataNotFound'

Router.onAfterAction ->
  GAnalytics.pageview()

#IronRouterProgress.configure
#  delay: false

Router.map ->
  @route 'chat'

  @route 'add'

  @route 'my'

  @route 'list',
    path: '/'
    waitOn: ->
    [
      Meteor.subscribe 'Servers'
    ]

  @route 'listTagged',
    path: '/tags/:tag'
    template: 'list'
    waitOn: ->
      [
        Meteor.subscribe 'Servers'
      ]

  @route 'details',
    path: '/ots/:_id'
    data: ->
      # https://github.com/EventedMind/iron-router/issues/665#issuecomment-44418128
      server = Servers.findOne
        _id: @params._id

      if not server? then return undefined

      server.statusHistory = StatusHistory.find
        serverId: @params._id
      .fetch()

      server
    onBeforeAction: (pause)->
      Session.set 'server', @params._id
      if not @data()
        @render '404'
        pause()
    waitOn: ->
      [
        Meteor.subscribe 'Servers', ['players']
        Meteor.subscribe 'StatusHistory',
          serverId: @params._id
      ]

  @route 'details/description',
    path: '/ots/:_id/description'
    template: 'detailsDescription'
    data: ->
      Servers.findOne
        _id: @params._id
    onBeforeAction: (pause)->
      Session.set 'server', @params._id
      if not @data()
        @render '404'
        pause()
    waitOn: ->
      Meteor.subscribe 'Servers', ['players']

  @route 'details/players',
    path: '/ots/:_id/players'
    template: 'detailsPlayers'
    data: ->
      Servers.findOne
        _id: @params._id
    onBeforeAction: (pause)->
      Session.set 'server', @params._id
      if not @data()
        @render '404'
        pause()
    waitOn: ->
      Meteor.subscribe 'Servers', ['players']

  @route 'faq'

Accounts.ui.config
  requestPermissions:
    otland: ['read']
