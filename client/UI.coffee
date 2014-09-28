UI.registerHelper 'moment', (time, format) ->
  moment(time).format(format)

UI.registerHelper 'moment_duration', (time) ->
  moment.duration(time, 'seconds').humanize()

UI.registerHelper 'moment_fromNow', (time, arg) ->
  arg = false if arg isnt true
  moment(time).fromNow(arg)

UI.registerHelper 'toFlag', (str) ->
  return if typeof str isnt 'string'
  str.toLowerCase().replace ' ', '-'

UI.registerHelper 'pagedown', (str) ->
  return if typeof str isnt 'string'
  converter = Markdown.getSanitizingConverter()
  return Spacebars.SafeString converter.makeHtml str

UI.registerHelper 'absoluteUrl', Meteor.absoluteUrlWithHash

UI.registerHelper 'equal2', (a1, a2) ->
  a1 == a2

UI.registerHelper 'not_equal2', (a1, a2) ->
  a1 != a2

UI.registerHelper 'numeral', (number, format) ->
  return if typeof number is 'undefined' or typeof format is 'undefined' or isNaN number
  numeral(number).format format

UI.registerHelper 'shorten', (str, chars) ->
  return if typeof str isnt 'string' or typeof chars isnt 'number'
  if (str.length > chars)
    str.substring(0, chars) + '...'
  else
    str

UI.registerHelper 'canManageServer', Meteor.canManageServer
