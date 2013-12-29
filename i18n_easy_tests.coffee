Tinytest.add(
    'setDefault/getDefault works'
    (test)->
        defaultLanguage = 'it'
        I18nEasy.setDefault defaultLanguage
        
        test.equal I18nEasy.getDefault(), defaultLanguage
)