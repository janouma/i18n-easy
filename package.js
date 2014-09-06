Package.describe({
    summary: "Simple way to handle i18n, including ability to add plurals within translations",
	homepage: "https://github.com/janouma/i18n-easy",
	author: "Judicaël Anouma <judicael.anouma@gmail.com>",
	version: "0.1.6",
	name: "janouma:i18n-easy",
	git: "https://github.com/janouma/i18n-easy.git"
});

Package.onUse(function(api, where){
	api.use(['coffeescript', 'minimongo', 'mongo-livedata']);
	api.use(['ui', 'deps'], 'client');

    api.addFiles(['i18n_easy.coffee', 'collections/i18n_easy_messages.coffee']);
	api.addFiles('i18n_easy_client.coffee', 'client');
	api.addFiles('i18n_easy_server.coffee', 'server');
    
    if (api.export) {
        api.export('I18nEasy');
    }
});

Package.onTest(function(api){
    api.use(['coffeescript', 'janouma:i18n-easy', 'tinytest', 'test-helpers']);
    api.addFiles(['tests/helpers.coffee','tests/i18n_init_tests.coffee']);
    api.addFiles('tests/i18n_easy_client_tests.coffee', 'client');
    api.addFiles('tests/i18n_easy_server_tests.coffee', 'server');
});