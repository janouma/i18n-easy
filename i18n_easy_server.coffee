class I18nServer extends I18nBase

    publish: (initialTranslations)->
        if initialTranslations and not I18nEasyMessages.find().count()
            @mapAll initialTranslations
    
        Meteor.publish(
            'translations'
            (languages)->
                check languages, [String]
                selector = $or: []
                selector.$or.push {language: language} for language in languages
                I18nEasyMessages.find selector
                
        )
        
    subscribe: -> Meteor._debug "Calling subscribe server side has no effect"

#==================================
I18nEasy = new I18nServer()