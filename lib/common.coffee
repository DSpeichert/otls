Meteor.absoluteUrlWithHash = (path) ->
  hash = ''
  try
    hash = '?' + _.find Meteor.settings.public.urlHashes, (item) ->
      item.url == '/' + path
    .hash;

  Meteor.absoluteUrl path + hash
