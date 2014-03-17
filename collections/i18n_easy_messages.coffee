@I18nEasyMessages = new Meteor.Collection 'i18n_easy_messages'

Meteor.methods {
	i18nEasyAddKey: (newKey, section)->
		do I18nEasy.checkWritePermissions
		check newKey, String
		check section, Match.Optional(String)

		singularKey = newKey.replace(/s$/gi, '')

		selector = key: new RegExp("^#{singularKey}s?$",'i')

		translation =
			key: newKey
			language: I18nEasy.getDefault()
			message: ''

		if section
			translation.section = selector.section = section
		else
			selector.section = $exists: no

		if I18nEasyMessages.findOne selector
			throw new Meteor.Error 409, "duplicated key '#{newKey}'"
		else
			I18nEasyMessages.insert translation

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
	i18nEasyRemoveKey: (key, section)->
		do I18nEasy.checkWritePermissions
		check key, String
		check section, Match.Optional(String)

		selector = key: key

		if section
			selector.section = section
		else
			selector.section = $exists: no

		Meteor._debug "#{I18nEasyMessages.remove selector} translations of #{if section then "#{section}/" else ''}'#{key}' has been removed"

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

	#==================================
	i18nEasyRemoveSection: (section)->
		do I18nEasy.checkWritePermissions
		check(
			section
			Match.Where (value)->
				check value, String
				value isnt 'i18n_easy_admin'
		)

		documentsRemoved = I18nEasyMessages.remove section: section
		Meteor._debug "#{documentsRemoved} translations in '#{section}' has been removed"

}