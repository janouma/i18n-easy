Router.map ->
    
    @route(
        'i18n-easy-admin'
        path: '/:language?/i18n-easy-admin'
        layoutTemplate: 'i18n-easy-layout'

        before: ->
            language = @params[0] or @params.language
        
            if language and I18nEasy.getLanguage() isnt language
                I18nEasy.setLanguage language

        waitOn: -> Meteor.subscribe I18nBase.LANGUAGES_PUBLICATION
    )
    