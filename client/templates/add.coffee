Template.add.events
  'submit #add-server': (event) ->
    event.preventDefault()
    Servers.insert
      host: $('#host').val()
      port: $('#port').val() || 7171
    , (error, id) ->
        if error
          new PNotify
            title: 'Oh No!'
            text: error.message
            type: 'error'
        else
          Router.go 'details',
            _id: id