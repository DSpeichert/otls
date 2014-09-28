Meteor.absoluteUrlWithHash = (path) ->
  hash = ''
  try
    hash = '?' + _.find Meteor.settings.public.urlHashes, (item) ->
      item.url == '/' + path
    .hash;

  Meteor.absoluteUrl path + hash

Meteor.canManageServer = (id, userId = Meteor.userId()) ->
  server = Servers.findOne
    _id: id

  user = Meteor.users.findOne
    userId: userId

  try
    if user.services.otland.user.username == doc.status.owner.name
      return true

  false
