I18nEasyMessages.allow {
	insert: -> yes
	update: -> yes
}

@fr = test_key: "test de clé"

@en =
    test_key: "key test"
    test_key_one: "test"
    test_key_two: ["test2", "all tests"]

@initData = ->
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

@resetData = ->
	Meteor.call 'clearI18nEasyMessages'
	do @initData

Meteor.call 'clearI18nEasyMessages'
if Meteor.isServer
	do @initData
	I18nEasy.publish default: 'en'

I18nEasy.subscribe default: 'en' if Meteor.isClient