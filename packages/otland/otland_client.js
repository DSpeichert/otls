Otland = {};

// Request Otland credentials for the user
// @param options {optional}
// @param credentialRequestCompleteCallback {Function} Callback function to call on
//   completion. Takes one argument, credentialToken on success, or Error on
//   error.
Otland.requestCredential = function (options, credentialRequestCompleteCallback) {
    // support both (options, callback) and (callback).
    if (!credentialRequestCompleteCallback && typeof options === 'function') {
        credentialRequestCompleteCallback = options;
        options = {};
    }

    var config = ServiceConfiguration.configurations.findOne({service: 'otland'});
    if (!config) {
        credentialRequestCompleteCallback && credentialRequestCompleteCallback(new ServiceConfiguration.ConfigError('Service not configured'));
        return;
    }

    var credentialToken = Random.id();

    var scope = (options && options.requestPermissions) || [];
    var flatScope = encodeURIComponent(scope.join(' '));

    var loginUrl =
        'http://otland.net/api/oauth/authorize' +
            '?client_id=' + config.clientId +
            '&response_type=code' +
            '&scope=' + flatScope +
            '&redirect_uri=' + Meteor.absoluteUrl('_oauth/otland?close') +
            '&state=' + credentialToken;

    Oauth.initiateLogin(credentialToken, loginUrl, credentialRequestCompleteCallback,
        {width: 1000, height: 1000});
};
