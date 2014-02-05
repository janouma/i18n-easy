class I18nServer extends I18nBase

	_mapAll = (translations, options)->
		if options?.overwrite
			imports = translations
		else
			imports = EJSON.clone translations
			I18nEasyMessages.find().forEach (document)-> delete imports[document.language]?[document.key]

		_addTranslation(language, messages) for language, messages of imports


	#==================================
	_addTranslation = (language, messages, section)->
		mistranslatedPlurals = []

		for key, message of messages
			if message?.constructor.name is 'Object'
				if not section
					_addTranslation language, message, key
				else
					Meteor._debug "sub sections are not allowed. #{section}/#{key} has been skipped"
			else
				mistranslatedPlurals.push "#{key}s"

				selector = {
					language: language
					key: key
				}
				selector.section = section if section?.length

				I18nEasyMessages.upsert(
					selector
					$set: message: message
				)

		if mistranslatedPlurals.length
			I18nEasyMessages.remove {
				key: $in: mistranslatedPlurals
			}

	#==================================
	map: (language, messages)->
		_addTranslation language, messages

	#==================================
	mapAll: (translations, options)->
		check translations, Object
		check options, Match.Optional(Object)
		_mapAll translations, options

	#==================================
	publish: (options)->
		defaultLanguage = options?.default
		check defaultLanguage, Match.Optional(String)
		@setDefault defaultLanguage if defaultLanguage?.length

		Meteor.publish(
			I18nBase.TRANSLATION_PUBLICATION
			(languages)->
				check(
					languages
					default: String
					actual: String
				)

				defaultKeys = []
				actualKeys = []

				I18nEasyMessages.find(language: $in: [languages.default, languages.actual]).forEach (document)->
					defaultKeys.push(document.key) if document.language is languages.default
					actualKeys.push(document.key) if document.language is languages.actual

				selector = $or: [
					{language: languages.actual}
					{language: languages.default, key: $nin: actualKeys}
					{key: $nin: defaultKeys}
				]

				I18nEasyMessages.find selector

		)

		Meteor.publish(
			I18nBase.LANGUAGES_PUBLICATION
			->
				distinctLanguages = {}

				liveQuery = I18nEasyMessages.find().observe {
					added: (document)=>
						if distinctLanguages[document.language]
							distinctLanguages[document.language].count++
						else
							@added(
								I18nEasyMessages._name
								document._id
								document
							)
							distinctLanguages[document.language] =
								count: 1
								document: document

					removed: (document)=>
						distinctLanguages[document.language].count--

						unless distinctLanguages[document.language].count
							@removed(
								I18nEasyMessages._name
								distinctLanguages[document.language].document._id
							)
							delete distinctLanguages[document.language]
				}

				@onStop -> do liveQuery.stop
				@ready()
		)


		Meteor.publish(
			I18nBase.SECTIONS_PUBLICATION
			->
				distinctSections = {}

				liveQuery = I18nEasyMessages.find(
					{section: $exists: yes}
				).observe {
					added: (document)=>
						if distinctSections[document.section]
							distinctSections[document.section].count++
						else
							@added(
								I18nEasyMessages._name
								document._id
								document
							)
							distinctSections[document.section] =
								count: 1
								document: document

					removed: (document)=>
						distinctSections[document.section].count--

						unless distinctSections[document.section].count
							@removed(
								I18nEasyMessages._name
								distinctSections[document.section].document._id
							)
							delete distinctSections[document.section]
				}

				@onStop -> do liveQuery.stop
				@ready()
		)


#==================================
I18nEasy = new I18nServer()