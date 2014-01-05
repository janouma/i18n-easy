class I18nClient extends I18nBase

    publish: -> Meteor._debug "Calling publish client side has no effect"
    
    subscribe: (options)->
        defaultLanguage = options?.default
        check defaultLanguage, String
    
        @setDefault defaultLanguage
        Meteor.subscribe(
            'translations'
            [@getDefault(), @getLanguage()]
        )

#==================================
I18nEasy = new I18nClient()
Handlebars.registerHelper('i18n', I18nEasy.i18n)