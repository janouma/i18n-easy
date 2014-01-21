@I18nEasyMessages = new Meteor.Collection 'i18n_easy_messages'

permissions =
    insert: -> yes # TODO use permission function
    update: -> yes # TODO use permission function

@I18nEasyMessages.allow permissions

Meteor.methods {
	i18nEasyAddKey: (newKey)->
		check newKey, String

		if I18nEasyMessages.find(key: new RegExp("^#{newKey}$",'i')).count()
			throw new Meteor.Error 409, "duplicated key '#{newKey}'"
		else
			I18nEasyMessages.insert(
				key: newKey
				language: I18nEasy.getDefault()
				message: ''
			)

	#==================================
	i18nEasySave: (translations)->
		check(
			translations
			[
				language: String
				key: String
				message: Match.OneOf(String, [String])
			]
		)

		for translation in translations
			I18nEasyMessages.upsert(
				{key: translation.key, language: translation.language}
				{$set: message: translation.message}
			)
}