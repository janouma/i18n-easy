@I18nEasyMessages = new Meteor.Collection 'i18n_easy_messages'

Meteor.methods {
	i18nEasyAddKey: (newKey)->
		do I18nEasy.checkWritePermissions
		check newKey, String

		singularKey = newKey.replace(/s$/gi, '')

		if I18nEasyMessages.find(key: new RegExp("^#{singularKey}s?$",'i')).count()
			throw new Meteor.Error 409, "duplicated key '#{newKey}'"
		else
			I18nEasyMessages.insert(
				key: newKey
				language: I18nEasy.getDefault()
				message: ''
			)

	#==================================
	i18nEasySave: (translations)->

		###DEBUG
		Meteor._debug 'Calling "i18nEasySave" with:'
		Meteor._debug translations
		###

		do I18nEasy.checkWritePermissions
		check(
			translations
			[
				language: String
				key: String
				message: Match.OneOf(String, [String])
				section: Match.Optional(String)
			]
		)

		for translation in translations
			selector = {key: translation.key, language: translation.language}

			newTranslation =
				key: translation.key
				message: translation.message
				language: translation.language

			if translation.section?.length
				newTranslation.section = selector.section = translation.section
			else
				selector.section = $exists: no

			I18nEasyMessages.upsert(
				selector
				newTranslation
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

	#==================================
	I18nEasyImport: (translations)->
		do I18nEasy.checkWritePermissions
		check translations, String
		imports = JSON.parse(translations)
		I18nEasy.mapAll imports, overwrite: yes

}