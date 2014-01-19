Package.describe({
    summary: "Simple way to handle i18n, including ability to add plurals within translations and admin ui"
});

Package.on_use(function(api, where){
    api.use(['coffeescript', 'minimongo', 'mongo-livedata', 'templating', 'handlebars', 'deps', 'iron-router', 'font-awesome'], 'client');
    api.use(['coffeescript', 'minimongo', 'mongo-livedata'], 'server');
    api.use('fast-render');
    
    api.add_files(['i18n_easy.coffee','collections/i18n_easy_messages.coffee']);

	var clientFiles = [];
	clientFiles.push('i18n_easy_client.coffee');
	clientFiles.push('router.coffee');
	clientFiles.push('client/view/i18n-easy-nav.html');
	clientFiles.push('client/view/i18n-easy-nav.coffee');
	clientFiles.push('client/view/i18n-easy-header.html');
	clientFiles.push('client/view/i18n-easy-footer.html');
	clientFiles.push('client/view/i18n-easy-layout.html');
	clientFiles.push('client/view/i18n-easy-translation.html');
	clientFiles.push('client/view/i18n-easy-translation.coffee');
	clientFiles.push('client/view/i18n-easy-admin.html');
	clientFiles.push('client/view/i18n-easy-admin.coffee');
	clientFiles.push('client/stylesheets/style.css');
	clientFiles.push('client/stylesheets/build-full-no-icons.min.css');

    api.add_files(clientFiles, 'client');

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