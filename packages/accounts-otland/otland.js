Accounts.oauth.registerService('otland');

if (Meteor.isClient) {
    Meteor.loginWithOtland = function (options, callback) {
        // support a callback without options
        if (!callback && typeof options === 'function') {
            callback = options;
            options = null;
        }

        var credentialRequestCompleteCallback = Accounts.oauth.credentialRequestCompleteHandler(callback);
        Otland.requestCredential(options, credentialRequestCompleteCallback);
    };
} else {
    Accounts.addAutopublishFields({
        // this works only if autopublish is on
        forLoggedInUser: ['services.otland.user']
    });
}
