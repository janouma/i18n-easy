class @I18nBase
	#Private

	_prefix = 'i18n-easy-'
	_defaultVarName = "#{_prefix}defaultLanguage"
	_varName = "#{_prefix}language"
	_writePermission = -> no

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
	_writeIsAllowed = (instance)-> _writePermission.call(instance)

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
	_translations = ->
		translations = {}
		defaultLanguage = _defaultLanguage()
		language = _language()

		I18nEasyMessages.find(
			{}
			sort: key: 1
		).forEach (result)->
			if result.key
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
						translation.plural.default = "#{result.message}s" unless translation.plural.default or not result.message.length

					translation.label = translation.singular.default if translation.singular.default

				if result.language is language
					[translation.singular.actual, translation.plural.actual] = if result.message.constructor.name is 'Array'
						result.message
					else
						translation.plural.default = "#{result.message}s" if result.message?.length
						[result.message, undefined]


		translation for key, translation of translations

	#==================================
	_translationFor = (key, options)->
		if options?.defaultLanguage isnt yes
			translation = I18nEasyMessages.findOne {
				language: _language()
				key: key
				$or: [
					{section: options?.section}
					{section: $exists: no}
				]
			}

		if options?.defaultLanguage or not translation and options?.useDefault isnt no
			translation = I18nEasyMessages.findOne {
				language: _defaultLanguage()
				key: key
				$or: [
					{section: options?.section}
					{section: $exists: no}
				]
			}

		translation?.message

	#==================================
	_singularFor = (key, options)->
		message = _translationFor(key, options)
		if message?.constructor.name is 'Array'
			message[0] unless not message[0]?.length
		else
			message unless not message?.length

	#==================================
	_pluralFor = (key, options)->
		message = _translationFor(key, options)
		if message?.constructor.name is 'Array'
			message[1] unless not message[1]?.length
		else
			"#{message}s" unless not message?.length or options?.autoPlural is no

	#Public

	@TRANSLATION_PUBLICATION: 'i18n-easy-translations'
	@LANGUAGES_PUBLICATION: 'i18n-easy-languages'

	setDefault: (language)->
		check language, String

		return if language is _defaultLanguage()
		_defaultLanguage language
		_language _defaultLanguage() unless _language()

	#==================================
	getDefault: ->
		_defaultLanguage()

	#==================================
	setLanguage: (language)->
		check language, String

		return if language is _language()
		_language language
		_defaultLanguage _language() unless _defaultLanguage()

	#==================================
	getLanguage: ->
		_language()

	#==================================
	getLanguages: ->
		distinctLanguages = []

		I18nEasyMessages.find(
			{}
			fields: language: yes
			sort: language: 1
		).forEach (result)-> distinctLanguages.push result.language unless result.language in distinctLanguages

		distinctLanguages

	#==================================
	i18n: (key, options)=>
		check key, String

		enhancedOptions = if typeof options is 'string' then section: options else options

		ironRouterPackage = 'iron-router'
		unless not Package[ironRouterPackage] or enhancedOptions?.section
			if enhancedOptions and enhancedOptions is options
				enhancedOptions = EJSON.clone options
			else
				enhancedOptions ?= {}

			enhancedOptions.section = Package[ironRouterPackage].Router.current().route.name

		message = _singularFor(key, enhancedOptions)
		unless message
			fallBack = "#{key}..." unless enhancedOptions?.fallBack is no
			if /s$/i.test key
				_pluralFor(key[0...key.length - 1], enhancedOptions) or fallBack
			else
				fallBack
		else
			message

	#==================================
	i18nDefault: (key, options)=>
		enhancedOptions = switch typeof options
			when 'object' then EJSON.clone options
			when 'string' then section: options
			else {}

		enhancedOptions.defaultLanguage = yes

		@i18n(
			key
			enhancedOptions
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

	#==================================
	prefix: (name)-> "#{_prefix}#{name}"

	#==================================
	checkWritePermissions: (details)->
		unless _writeIsAllowed(@)
			throw new Meteor.Error(
				403
				"write forbidden (set permissions properly through 'allowWrite' operation)"
				details
			)

	#==================================
	writeIsAllowed: -> _writeIsAllowed(@)

	#==================================
	allowWrite: (writePermission)->
		check(
			writePermission
			Match.Where (val)-> typeof val is 'function'
		)

		_writePermission = writePermission