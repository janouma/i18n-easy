Tinytest.add(
    'setDefault/getDefault works'
    (test)->
        defaultLanguage = 'it'
        I18nEasy.setDefault defaultLanguage
        test.equal I18nEasy.getDefault(), defaultLanguage
)

Tinytest.add(
    'setLanguage/getLanguage works'
    (test)->
        language = 'es'
        I18nEasy.setLanguage language
        test.equal I18nEasy.getLanguage(), language
)

Tinytest.add(
    'translate works'
    (test)->
        test.equal(
            I18nEasy.translate 'unkown_key'
            "unkown_key..."
        )
        
        I18nEasy.setLanguage 'fr'
        do Deps.flush

        testKey = 'test_key'
        
        test.equal(
            I18nEasy.translate testKey
            fr[testKey]
        )
        
        I18nEasy.setLanguage 'en'

        test.equal(
            I18nEasy.translate testKey 
            en[testKey]
        )
)

Tinytest.add(
    'pluralize works'
    (test)->
        testKeyOne = 'test_key_one'
        testKeyTwo = 'test_key_two'
        I18nEasy.setLanguage 'en'
        do Deps.flush
        
        test.equal(
            I18nEasy.translate "#{testKeyOne}s"
            "#{en[testKeyOne]}s"
        )
        test.equal(
            I18nEasy.translate testKeyTwo
            en[testKeyTwo][0]
        )
        test.equal(
            I18nEasy.translate "#{testKeyTwo}s"
            en[testKeyTwo][1]
        )
)

Tinytest.add(
    'getLanguages works'
    (test)->
        test.equal(
            I18nEasy.getLanguages()
            ['fr', 'en']
        )
)