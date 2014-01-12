class @I18nBase
	#Private

	_defaultVarName = 'i18n-defaultLanguage'
	_varName = 'i18n-language'

	if Meteor.isClient
		_context =
			set: (varName, value)->
				Session.set varName, value
			get: (varName)->
				Session.get varName

	if Meteor.isServer
		_context =
			set: (varName, value)->
				@[varName] = value
			get: (varName)->
				@[varName]

	#==================================
	_defaultLanguage = (language)->
		if language
			_context.set _defaultVarName, language
		else
			_context.get _defaultVarName

	#==================================
	_language = (language)->
		if language
			_context.set _varName, language
		else
			_context.get _varName

	#==================================
	_mapAll = (translations)->
		_addTranslation(language, messages) for language, messages of translations

	#==================================
	_addTranslation = (language, messages)->
		for key, message of messages
			I18nEasyMessages.upsert(
					{
						language: language
						key: key
					}
				$set:
					message: message
			)

	#==================================
	_translations = ->
		translations = {}
		defaultLanguage = _defaultLanguage()
		language = _language()

		results = I18nEasyMessages.find(
				{}
			sort:
				key: 1
		).fetch()

		for result in results when result.key
			translation =
				translations[result.key] ?=
					key: result.key
					label: "{{#{result.key}}}"
					singular: {}
					plural: {}

			if result.language is defaultLanguage
				if result.message.constructor.name is 'Array'
					translation.singular.default = result.message[0]
					translation.plural.default = result.message[1] unless translation.plural.default
				else
					translation.singular.default = result.message
					translation.plural.default = "#{result.message}s" unless translation.plural.default

				translation.label = translation.singular.default

			if result.language is language
				[translation.singular.actual, translation.plural.actual] = if result.message.constructor.name is 'Array'
					result.message
				else
					translation.plural.default = "#{result.message}s"
					[result.message, undefined]


		translation for key, translation of translations

	#==================================
	_translationFor = (key, options)->
		if options?.defaultLanguage isnt yes
			translation = I18nEasyMessages.findOne {
				language: _language()
				key: key
			}

		if options?.defaultLanguage or not translation and options?.useDefault isnt no
			translation = I18nEasyMessages.findOne {
				language: _defaultLanguage()
				key: key
			}

		translation?.message

	#==================================
	_singularFor = (key, options)->
		message = _translationFor(key, options)
		if message?.constructor.name is 'Array'
			message[0]
		else
			message

	#==================================
	_pluralFor = (key, options)->
		message = _translationFor(key, options)
		if message?.constructor.name is 'Array'
			message[1]
		else
			"#{message}s" unless not message or options?.autoPlural is no

	#Public

	@TRANSLATION_PUBLICATION: 'i18n-easy-translations'
	@LANGUAGES_PUBLICATION: 'i18n-easy-languages'

	setDefault: (language)->
		check language, String

		return if language is _defaultLanguage()
		_defaultLanguage language
		_language _defaultLanguage unless _language()

	#==================================
	getDefault: ->
		_defaultLanguage()

	#==================================
	setLanguage: (language)->
		check language, String

		return if language is _language()
		_language language
		_defaultLanguage _language unless _defaultLanguage()

	#==================================
	getLanguage: ->
		_language()

	#==================================
	map: (language, messages)->
		_addTranslation language, messages

	#==================================
	mapAll: (translations)->
		_mapAll translations

	#==================================
	getLanguages: ->
		results = I18nEasyMessages.find(
				{}
				{fields:
					language: yes}
		).fetch()

		distinctLanguages = []
		distinctLanguages.push result.language for result in results when result.language not in distinctLanguages
		distinctLanguages

	#==================================
	i18n: (key, options)=>
		check key, String

		message = _singularFor(key, options)
		unless message
			fallBack = "#{key}..." unless options?.fallBack is no
			if /s$/i.test key
				_pluralFor(key[0...key.length - 1], options) or fallBack
			else
				fallBack
		else
			message

	#==================================
	i18nDefault: (key)=>
		@i18n(
				key
			defaultLanguage: yes
		)

	#==================================
	i18ns: (key, options)=>
		@i18n("#{key}s", options)

	#==================================
	translate: (key)=>
		@i18n(
				key
			fallBack: no
			autoPlural: no
			useDefault: no
		)

	#==================================
	translatePlural: (key)=>
		@translate "#{key}s"

	#==================================
	translations: =>
		_translations()