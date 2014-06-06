# DOCS: http://github.differential.io/reststop2/

RESTstop.configure
  use_auth: false
  api_path: 'api'
  pretty_json: true

RESTstop.add 'announce', { method: 'GET' }, ->
  ip = @request.headers['x-forwarded-for'] || @request.client._peername.address
  console.log 'Got announce from: ' + ip

  server = Servers.findOne
    'status.ip': ip
    port: 7171

  if server?
    console.log 'Skipping announce from ' + ip + ' - already exists as ' + server._id
    return 'Your server is listed at http://otls.net/ots/' + server._id

  try
    status = Servers.getParsedStatus(ip)
    if status is false
      return [503, 'Your server did not return any data, cannot at to the list!']
    status.uptime = 100
    id = Servers.insert
      host: ip
      port: 7171
      createdAt: new Date()
      status: status
      statusAt: new Date()
      statusCount: 0
      statusFail: 0

    return 'We added your server to our list! You can find it at http://otls.net/ots/' + id
  catch e
    console.log e.message, e.details
    return [503, 'We could not connect to your server! Check your firewall and/or port redirection. Chances are that nobody can join your server.']
