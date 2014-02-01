@I18nEasyMessages = new Meteor.Collection 'i18n_easy_messages'

Meteor.methods {
	i18nEasyAddKey: (newKey)->
		do I18nEasy.checkWritePermissions
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
		do I18nEasy.checkWritePermissions
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
		do I18nEasy.checkWritePermissions
		check key, String
		Meteor._debug "#{I18nEasyMessages.remove key: key} translations of '#{key}' has been removed"

	#==================================
	i18nEasyAddLanguage: (newLanguage)->
		do I18nEasy.checkWritePermissions
		check newLanguage, String
		lowerCaseLanguage  = newLanguage.toLowerCase()

		if I18nEasyMessages.find(language: new RegExp("^#{lowerCaseLanguage}$",'i')).count()
			throw new Meteor.Error 409, "duplicated language '#{lowerCaseLanguage}'"
		else
			I18nEasyMessages.insert {
				key: lowerCaseLanguage
				language: lowerCaseLanguage
				message: ''
			}

	#==================================
	i18nEasyRemoveLanguage: (language)->
		do I18nEasy.checkWritePermissions
		check(
			language
			Match.Where (value)->
				check value, String
				value isnt I18nEasy.getDefault()
		)

		documentsRemoved = I18nEasyMessages.remove {
			$or: [
				{language: language}
				{key: language}
			]
		}

		Meteor._debug "#{documentsRemoved} translations in '#{language}' has been removed"

}