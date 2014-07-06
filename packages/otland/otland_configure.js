Template.configureLoginServiceDialogForOtland.siteUrl = function () {
    return Meteor.absoluteUrl();
};

Template.configureLoginServiceDialogForOtland.fields = function () {
    return [
        {property: 'clientId', label: 'Client ID'},
        {property: 'secret', label: 'Client Secret'}
    ];
};
