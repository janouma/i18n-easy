class I18nClient extends I18nBase

    publish: -> Meteor._debug "Calling publish client side has no effect"
    
    subscribe: (options)->
        defaultLanguage = options?.default
        check defaultLanguage, String
    
        @setDefault defaultLanguage
        Meteor.subscribe(
            I18nBase.TRANSLATION_PUBLICATION
            [@getDefault(), @getLanguage()]
        )

#==================================
I18nEasy = new I18nClient()

Handlebars.registerHelper('i18n', I18nEasy.i18n)
Handlebars.registerHelper('i18ns', I18nEasy.i18ns)
Handlebars.registerHelper('translate', I18nEasy.translate)
Handlebars.registerHelper('translatePlural', I18nEasy.translatePlural)
Handlebars.registerHelper('i18nTranslations', I18nEasy.translations)

Handlebars.registerHelper(
    'pathToLanguage'
    (language)->
        try
            Router.current().route.path(language: language)
        catch error
            Meteor._debug """
            Warning: #{error.message}
             |_route: #{Router.current().route.name}
             |_path: #{Router.current().path}
             |_template: #{Router.current().template}
             |_language: #{language}
            """
            "/#{language}"
)