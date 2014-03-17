Package.describe({
    summary: "Simple way to handle i18n, including ability to add plurals within translations"
});

Package.on_use(function(api, where){
	api.use(['coffeescript', 'minimongo', 'mongo-livedata']);
    api.use(['handlebars', 'deps'], 'client');

    api.add_files(['i18n_easy.coffee', 'collections/i18n_easy_messages.coffee']);
	api.add_files('i18n_easy_client.coffee', 'client');
	api.add_files('i18n_easy_server.coffee', 'server');
    
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