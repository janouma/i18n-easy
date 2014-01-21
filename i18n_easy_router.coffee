Router.map ->
    
    @route(
        'i18n_easy_admin'
        path: '/:language?/i18n-easy-admin'
        layoutTemplate: 'i18n_easy_layout'

        before: ->
            language = @params.language

            if language and I18nEasy.getLanguage() isnt language
                I18nEasy.setLanguage language

        waitOn: -> Meteor.subscribe I18nBase.LANGUAGES_PUBLICATION
    )
