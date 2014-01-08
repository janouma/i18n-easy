Package.describe({
    summary: "Simple way to handle i18n, including ability to add plurals within translations and admin ui"
});

Package.on_use(function(api, where){
    api.use(['coffeescript', 'minimongo', 'mongo-livedata', 'templating', 'handlebars', 'deps', 'iron-router'], 'client');
    api.use(['coffeescript', 'minimongo', 'mongo-livedata'], 'server');
    
    api.add_files(['i18n_easy.coffee','collections/i18n_easy_messages.coffee']);
    api.add_files(['i18n_easy_client.coffee', 'router.coffee', 'client/view/i18n-easy-nav.html', 'client/view/i18n-easy-nav.coffee', 'client/view/i18n-easy-header.html', 'client/view/i18n-easy-footer.html', 'client/view/i18n-easy-layout.html','client/view/i18n-easy-admin.html'], 'client');
    api.add_files(['i18n_easy_server.coffee', 'server/publications.coffee'], 'server');
    
    if (api.export) {
        api.export('I18nEasy');
    }
});

Package.on_test(function(api){
    api.use(['coffeescript', 'i18n-easy', 'tinytest', 'test-helpers']);
    api.add_files(['tests/helpers.coffee','tests/i18n_init_tests.coffee']);
    api.add_files('tests/i18n_easy_client_tests.coffee', 'client');
    api.add_files('tests/i18n_easy_server_tests.coffee', 'server');
});