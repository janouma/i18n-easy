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