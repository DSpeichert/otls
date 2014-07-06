Package.describe({
    summary: 'Login service for Otland accounts'
});

Package.on_use(function (api) {
    api.use('accounts-base', ['client', 'server']);
    api.imply('accounts-base', ['client', 'server']);
    api.use('accounts-oauth', ['client', 'server']);
    api.use('otland', ['client', 'server']);
    api.add_files('otland.js');
});
