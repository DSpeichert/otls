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

  'click #edit-description': (event) ->
    event.preventDefault()
    $('#description-editor').toggle()

  'change #wmd-input': (event) ->
    Servers.update
      _id: Session.get 'server'
    ,
      $set:
        description: event.currentTarget.value

Template.details.rendered = ->
  converter1 = Markdown.getSanitizingConverter()
  editor1 = new Markdown.Editor converter1
  editor1.run()

  $('#fb-link').attr 'href', 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(Meteor.absoluteUrl Router.current().path)
  $('#fb-link').popupWindow
    height: 600
    width: 500
    top: 50
    left: 50
    menubar: false
    scrollbars: false
    toolbar: false
