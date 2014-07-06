Otland = {};

Oauth.registerService('otland', 2, null, function (query) {
    var response = getTokens(query);
    var identity = getIdentity(response);

    var serviceData = _.extend({timestamp: new Date()}, response, identity);
    serviceData.id = identity.user.user_id;
    return {
        serviceData: serviceData,
        options: {profile: {name: identity.user.username}}
    };
});

var userAgent = 'Meteor';
if (Meteor.release)
    userAgent += '/' + Meteor.release;

var getTokens = function (query) {
    var config = ServiceConfiguration.configurations.findOne({service: 'otland'});
    if (!config)
        throw new ServiceConfiguration.ConfigError('Service not configured');

    var response;
    try {
        response = HTTP.post(
            'http://otland.net/api/oauth/token', {
                headers: {
                    Accept: 'application/json',
                    "User-Agent": userAgent
                },
                params: {
                    code: query.code,
                    client_id: config.clientId,
                    client_secret: config.secret,
                    grant_type: 'authorization_code',
                    redirect_uri: Meteor.absoluteUrl('_oauth/otland?close')
                }
            });
    } catch (err) {
        throw _.extend(new Error('Failed to complete OAuth handshake with Otland. ' + err.message),
            {response: err.response});
    }
    if (response.data.error) { // if the http response was a json object with an error attribute
        throw new Error('Failed to complete OAuth handshake with Otland. ' + response.data.error);
    } else {
        console.log(response.data);
        return response.data;
    }
};

var getIdentity = function (accessToken) {
    try {
        return HTTP.get(
            'http://otland.net/api/users/me', {
                params: {
                    oauth_token: accessToken.access_token
                }
            }).data;
    } catch (err) {
        throw _.extend(new Error('Failed to fetch identity from Otland. ' + err.message),
            {response: err.response});
    }
};


Otland.retrieveCredential = function (credentialToken) {
    return Oauth.retrieveCredential(credentialToken);
};
