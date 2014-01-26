@I18nEasyMessages = new Meteor.Collection 'i18n_easy_messages'

permissions =
    insert: -> validDocument
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

	#==================================
	i18nEasyRemoveKey: (key)->
		check key, String
		Meteor._debug "#{I18nEasyMessages.remove key: key} translations of '#{key}' has been removed"

	#==================================
	i18nEasyAddLanguage: (newLanguage)->
		check newLanguage, String
		lowerCaseLanguage  = newLanguage.toLowerCase()

		if I18nEasyMessages.find(language: new RegExp("^#{lowerCaseLanguage}$",'i')).count()
			throw new Meteor.Error 409, "duplicated language '#{lowerCaseLanguage}'"
		else
			I18nEasyMessages.insert {
				key: lowerCaseLanguage
				language: I18nEasy.getDefault()
				message: ''
			}
			I18nEasyMessages.insert {
				key: lowerCaseLanguage
				language: lowerCaseLanguage
				message: ''
			}
}