Tinytest.add(
    'map adds keys to i18n_easy_messages collection'
    (test)->
        Meteor.call 'clearI18nEasyMessages'
        
        language = 'en'
        newTestKey = 'new_test_key'
        translation = {}
        translation[newTestKey] = "new test key"
        I18nEasy.map language, translation
        
        message = I18nEasyMessages.findOne {
            language: language
            key: newTestKey
        }
        
        test.equal(
            message?.message
            translation[newTestKey]
        )
)