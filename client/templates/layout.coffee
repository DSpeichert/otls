$ ->
  if !!document.createElementNS('http://www.w3.org/2000/svg','svg').createSVGRect
    $('body').addClass 'svg'
  else
    $('body').addClass 'no-svg'

Template.layout.events
  'change #search-term': (event) ->
    Session.set 'search-term', event.currentTarget.value

  'submit #search-form': (event) ->
    event.preventDefault()
    Router.go 'list' if Router.current().route.name not in ['list', 'listTagged']

Template.layout.rendered = ->
  $('body').tooltip
    selector: '[data-toggle="tooltip"]'
