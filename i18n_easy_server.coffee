class I18nServer extends I18nBase

	publish: (options)->
		initialTranslations = options?.translations
		defaultLanguage = options?.default
		check defaultLanguage, String

		@setDefault defaultLanguage

		if initialTranslations and not I18nEasyMessages.find().count()
			@mapAll initialTranslations

		Meteor.publish(
			I18nBase.TRANSLATION_PUBLICATION
			(languages)->
				check languages, [String]
				selector =
					$or: []
				selector.$or.push {language: language} for language in languages
				I18nEasyMessages.find selector

		)

	subscribe: ->
		Meteor._debug "Calling subscribe server side has no effect"


#==================================
I18nEasy = new I18nServer()