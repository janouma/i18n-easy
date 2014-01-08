navigatorLanguage = ->
    results = /(\w{2}).*/gi.exec window.navigator.language
    results.length > 1 and results[1]

Router.map ->
    
    @route(
        'i18n-easy-admin'
        path: '/:language?/i18n-easy-admin'
        layoutTemplate: 'i18n-easy-layout'

        before: ->
            language = @params[0] or @params.language or navigatorLanguage() or I18nEasy.getDefault()
        
            if language and I18nEasy.getLanguage() isnt language
                I18nEasy.setLanguage language

        waitOn: -> Meteor.subscribe I18nBase.LANGUAGES_PUBLICATION
    )
    