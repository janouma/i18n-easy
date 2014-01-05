_defaultVarName = 'i18n-defaultLanguage'
_varName = 'i18n-language'

_serverDefaultLanguage = undefined
_serverLanguage = undefined

#==================================
_defaultLanguage = (language)->
    if language
        if Meteor.isServer
            _serverDefaultLanguage = language
        else
            Session.set _defaultVarName, language
    else
        if Meteor.isServer
            _serverDefaultLanguage
        else
            Session.get _defaultVarName

#==================================
_language = (language)->
    if language
        if Meteor.isServer
            _serverLanguage = language
        else
            Session.set _varName, language
    else
        if Meteor.isServer
            _serverLanguage
        else
            Session.get _varName

#==================================
_publish = ->
    if Meteor.isServer
        #DEBUG
        Meteor._debug "Creating meteor publication"
        
        Meteor.publish(
            'translations'
            (languages)->
                check languages, [String]
                
                #DEBUG
                Meteor._debug "Publishing '#{languages}'"
                
                selector = $or: []
                selector.$or.push {language: language} for language in languages
                I18nEasyMessages.find selector
                
        )

#==================================
_subscribe = (options)->
    if Meteor.isClient
        defaultLanguage = options?.default
        check defaultLanguage, String

        _defaultLanguage defaultLanguage
        _language defaultLanguage unless _language()
        
        #DEBUG
        Meteor._debug "Subscribing to '#{_language()}'"
        
        Meteor.subscribe(
            'translations'
            [_defaultLanguage(), _language()]
            ->
                #DEBUG
                Meteor._debug "Subscription to '#{[_defaultLanguage(), _language()]}' is ready"
        )

#==================================
_addTranslation = (language, messages)->
    for key, message of messages
        I18nEasyMessages.upsert(
            {
                language: language
                key: key
            }
            $set: message: message
        )

#==================================
_translationFor = (key)->
    translation = I18nEasyMessages.findOne {
        language: _language()
        key: key
    }

    unless translation
        translation = I18nEasyMessages.findOne {
            language: _defaultLanguage()
            key: key
        }
    
    translation?.message

#==================================
_singularFor = (key)->
    message = _translationFor key
    if message?.constructor.name is 'Array'
        message[0]
    else
        message

#==================================
_pluralFor = (key)->
    message = _translationFor(key)
    if message?.constructor.name is 'Array'
        message[1]
    else
        "#{message}s" unless not message

#==================================
I18nEasy =

    publish: (defaultLanguage)-> do _publish
        
    subscribe: (options)-> _subscribe options
    
    setDefault: (language)->
        check language, String
        
        return if language is _defaultLanguage()
        _defaultLanguage language
        _language _defaultLanguage unless _language()
        
    getDefault: -> _defaultLanguage()
    
    setLanguage: (language)->
        check language, String
        
        return if language is _language()
        _language language
        _defaultLanguage _language unless _defaultLanguage()
        
    getLanguage: -> _language()

    map: (language, messages)-> _addTranslation language, messages
        
    getLanguages: ->
        results = I18nEasyMessages.find(
            {}
            {fields: language: yes}
        ).fetch()
        
        distinctLanguages = []
        distinctLanguages.push result.language for result in results when result.language not in distinctLanguages
        distinctLanguages
        
    i18n: (key)->
        check key, String
        
        message = _singularFor key
        
        #DEBUG
        Meteor._debug "Getting translation for '#{key}' '#{_language()}' (#{message})"

        unless message
            fallBack = "{{#{key}}}"
            if /s$/i.test key then _pluralFor(key[0...key.length-1])  or fallBack else fallBack
        else
            message
            
    translate: (key)-> @i18n key


#==================================
Handlebars.registerHelper('i18n', I18nEasy.i18n) if Meteor.isClient
