Package.describe({
    summary: "Simple way to handle i18n, including ability to add plurals within translations and admin ui"
});

Package.on_use(function(api, where){
    api.use(['coffeescript', 'minimongo', 'mongo-livedata', 'templating', 'handlebars', 'deps'], ['client']);
    api.add_files(['i18n_easy.coffee'], ['client']);
    
    if (api.export) {
        api.export('I18nEasy', 'client');
    }
});