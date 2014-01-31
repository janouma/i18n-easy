Package.describe({
    summary: "Simple way to handle i18n, including ability to add plurals within translations and admin ui"
});

Package.on_use(function(api, where){
    api.use(['coffeescript', 'minimongo', 'mongo-livedata', 'templating', 'handlebars', 'deps', 'font-awesome'], 'client');
    api.use(['coffeescript', 'minimongo', 'mongo-livedata'], 'server');
    api.use('iron-router');
    
    api.add_files(['i18n_easy.coffee', 'i18n_easy_permissions.coffee','collections/i18n_easy_messages.coffee']);

	var clientFiles = [];
	clientFiles.push('i18n_easy_client.coffee');
	clientFiles.push('i18n_easy_router.coffee');
	clientFiles.push('client/helpers/alert.coffee');
	clientFiles.push('client/view/i18n_easy_nav.html');
	clientFiles.push('client/view/i18n_easy_nav.coffee');
	clientFiles.push('client/view/i18n_easy_header.html');
	clientFiles.push('client/view/i18n_easy_footer.html');
	clientFiles.push('client/view/i18n_easy_layout.html');
	clientFiles.push('client/view/i18n_easy_translation.html');
	clientFiles.push('client/view/i18n_easy_translation.coffee');
	clientFiles.push('client/view/i18n_easy_admin.html');
	clientFiles.push('client/view/i18n_easy_admin.coffee');
	clientFiles.push('client/stylesheets/style.css');
	clientFiles.push('client/stylesheets/build-full-no-icons.min.css');

    api.add_files(clientFiles, 'client');

    api.add_files(['i18n_easy_server.coffee', 'i18n_easy_router.coffee'], 'server');
    
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