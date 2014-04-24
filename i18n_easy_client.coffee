ironRouterPackage = 'iron-router'

class I18nClient extends I18nBase

	_checkCallbacks = (options = {})->
		OptionalFunction = Match.Optional(
			Match.Where (val)-> typeof val is 'function'
		)
		check options.translationsReady, OptionalFunction
		check options.languagesReady, OptionalFunction
		check options.sectionsReady, OptionalFunction

	_checkSections = (options = {})->
		if options.sections
			check options.sections, [String]
			options.sections
		else
			[Package[ironRouterPackage].Router.current().route.name] if Package[ironRouterPackage] and Package[ironRouterPackage].Router.current()


	subscribe: (options)->
		defaultLanguage = options?.default
		check defaultLanguage, Match.Optional(String)
		@setDefault defaultLanguage if defaultLanguage?.length
		do @defaultSubscribe


	defaultSubscribe: (options)->
		check @getDefault(), String
		_checkCallbacks options
		sections = _checkSections options

		[
			Meteor.subscribe(
				I18nBase.TRANSLATION_PUBLICATION
				{default: @getDefault(), actual: @getLanguage(), sections: sections}
				options?.translationsReady
			)

			Meteor.subscribe(
				I18nBase.LANGUAGES_PUBLICATION
				options?.languagesReady
			)
		]


	subscribeForTranslation: (options)->
		_checkCallbacks options
		sections = _checkSections options

		subscriptions = @defaultSubscribe options
		subscriptions.push(
			Meteor.subscribe(
				I18nBase.TRANSLATION_PUBLICATION
				{default: @getDefault(), actual: @getDefault(), sections: sections}
				options?.translationsReady
			)
		)
		subscriptions.push(
			Meteor.subscribe I18nBase.SECTIONS_PUBLICATION
			options?.sectionsReady
		)
		subscriptions


	mapAll: -> Meteor._debug 'mapAll client simulation (no effect – usefull for remote method call)'


#==================================
I18nEasy = new I18nClient()

UI.registerHelper('i18n', (key, options)-> I18nEasy.i18n key, options.hash)
UI.registerHelper('i18ns', (key, options)-> I18nEasy.i18ns key, options.hash)
UI.registerHelper('translate', I18nEasy.translate)
UI.registerHelper('translatePlural', I18nEasy.translatePlural)
UI.registerHelper('i18nDefault', (key, options)-> I18nEasy.i18nDefault key, options.hash)
UI.registerHelper('ghost', -> ghostSuffix: '-ghost')

UI.registerHelper(
	'pathToLanguage'
	(language)->
		if Package[ironRouterPackage]
			try
				parameters = language: language

				if Package[ironRouterPackage].Router.current()?.params.section
					parameters.section = Package[ironRouterPackage].Router.current().params.section

				Package[ironRouterPackage].Router.current()?.route.path(parameters)
			catch error
				Meteor._debug """
				Warning: #{error.message}
				 |_route: #{Package[ironRouterPackage].Router.current()?.route.name}
				 |_path: #{Package[ironRouterPackage].Router.current()?.path}
				 |_language: #{language}
				"""
				"/#{language}"
		else
			Meteor._debug 'To benefit from the "pathToLanguage" helper you need to install "iron-router" smart package (https://atmosphere.meteor.com/package/iron-router)'
)