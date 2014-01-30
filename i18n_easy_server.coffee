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

				defaultKeys = []

				I18nEasyMessages.find(
					{language: languages[0]}
					{fields: key: yes}
				)
				.forEach (document)-> defaultKeys.push document.key

				selector = $or: [key: $nin: defaultKeys]
				selector.$or.push {language: language} for language in languages

				I18nEasyMessages.find selector

		)

		Meteor.publish(
			I18nBase.LANGUAGES_PUBLICATION
			->
				distinctLanguages = {}

				liveQuery = I18nEasyMessages.find(
					{}
					{fields: language: yes}
				).observe {
					added: (language)=>
						if distinctLanguages[language.language]
							distinctLanguages[language.language].count++
						else
							@added(
								I18nEasyMessages._name
								language._id
								language
							)
							distinctLanguages[language.language] =
								count: 1
								document: language

					removed: (language)=>
						distinctLanguages[language.language].count--

						unless distinctLanguages[language.language].count
							@removed(
								I18nEasyMessages._name
								distinctLanguages[language.language].document._id
							)
							delete distinctLanguages[language.language]
				}

				@onStop -> do liveQuery.stop
				@ready()
		)


	subscribe: ->
		Meteor._debug "Calling subscribe server side has no effect"

	defaultSubscribe: ->
		Meteor._debug "Calling defaultSubscribe server side has no effect"


#==================================
I18nEasy = new I18nServer()