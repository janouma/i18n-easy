Meteor._debug "Clearing 'i18n_easy_messages' collection"
Meteor.call 'clearI18nEasyMessages'

@fr = test_key: "test de clé"

@en =
    test_key: "key test"
    test_key_one: "test"
    test_key_two: ["test2", "all tests"]
    
for key, message of @fr
    I18nEasyMessages.insert {
        language: 'fr'
        key: key
        message: message
    }
    
for key, message of @en
    I18nEasyMessages.insert {
        language: 'en'
        key: key
        message: message
    }

I18nEasy.publish()
I18nEasy.subscribe default: 'en'