Tinytest.add(
    'map adds keys to i18n_easy_messages collection'
    (test)->
        I18nEasyMessages.remove()
        
        testKey = 'test_key'
        en = {}
        en[testKey] = "test key"
        I18nEasy.map 'en', en
        messagesCursor = do I18nEasyMessages.find
        messages = (do messagesCursor.fetch)?[0]
        
        test.equal(
            messages?[testKey]?.en
            en[testKey]
        )
        
        I18nEasyMessages.remove()
)