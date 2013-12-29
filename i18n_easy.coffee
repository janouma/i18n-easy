_defaultLanguage = 'fr'
_language = _defaultLanguage
_languages = {}
_messages = {}
_dep = new Deps.Dependency()

#==================================
addTranslation = (language, messages)->
    for key, message of messages
        translation = _messages[key]
        switch translation?.constructor.name
            when 'Object'
                translation[language] = message
            
            when 'String', 'Array'
                _messages[key] = {}
                _messages[key][_defaultLanguage] = translation
                _messages[key][language] = message
                
            else _messages[key] = message

#==================================
translationFor = (key)-> _messages[key]?[_language] or _messages[key]?[_defaultLanguage] or _messages[key]

#==================================
singularFor = (key)->
    message = translationFor key
    if message?.constructor.name is 'Array'
        message[0]
    else
        message

#==================================
pluralFor = (key)->
    message = translationFor(key)
    if message?.constructor.name is 'Array'
        message[1]
    else
        "#{message}s" unless not message

#==================================
I18nEasy =
    setDefault: (language)->
        throw new Error "language argument must be of type 'String'" if language?.constructor.name isnt 'String'
        _defaultLanguage = language
        _dep.changed()
        
    getDefault: ->
        _dep.depend()
        _defaultLanguage
    
    setLanguage: (language)->
        throw new Error "language argument must be of type 'String'" if language?.constructor.name isnt 'String'
        _language = language
        _dep.changed()
        
    getLanguage: ->
        _dep.depend()
        _language

    map: (language, messages)->
        _languages[language] = yes
        addTranslation language, messages
        _dep.changed()
        
    getLanguages: ->
        _dep.depend()
        Object.keys _languages
        
    i18n: (key)->
        _dep.depend()
        throw new Error "key must be of type 'String'" if key?.constructor.name isnt 'String'
        message = singularFor key

        unless message
            fallBack = "{{#{key}}}"
            if /s$/i.test key then pluralFor(key[0...key.length-1])  or fallBack else fallBack
        else
            message
            
    translate: (key)-> @i18n key


#==================================
Handlebars.registerHelper 'i18n', I18nEasy.i18n
