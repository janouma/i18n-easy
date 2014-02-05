class I18nClient extends I18nBase

	_checkCallbacks = (options = {})->
		OptionalFunction = Match.Optional(
			Match.Where (val)-> typeof val is 'function'
		)
		check options.translationsReady, OptionalFunction
		check options.languagesReady, OptionalFunction
		check options.sectionsReady, OptionalFunction


	subscribe: (options)->
		defaultLanguage = options?.default
		check defaultLanguage, Match.Optional(String)
		@setDefault defaultLanguage if defaultLanguage?.length
		do @defaultSubscribe


	defaultSubscribe: (options)->
		check @getDefault(), String
		_checkCallbacks options

		[
			Meteor.subscribe(
				I18nBase.TRANSLATION_PUBLICATION
				{default: @getDefault(), actual: @getLanguage()}
				options?.translationsReady
			)

			Meteor.subscribe(
				I18nBase.LANGUAGES_PUBLICATION
				options?.languagesReady
			)
		]


	subscribeForTranslation: (options)->
		_checkCallbacks options

		subscriptions = @defaultSubscribe options
		subscriptions.push(
			Meteor.subscribe(
				I18nBase.TRANSLATION_PUBLICATION
				{default: @getDefault(), actual: @getDefault()}
				options?.translationsReady
			)
		)
		subscriptions.push(
			Meteor.subscribe I18nBase.SECTIONS_PUBLICATION
			options?.sectionsReady
		)
		subscriptions


	mapAll: -> Meteor._debug 'mapAll client simulation (no effect – usefull to remote method call)'


#==================================
I18nEasy = new I18nClient()

Handlebars.registerHelper('i18n', I18nEasy.i18n)
Handlebars.registerHelper('i18ns', I18nEasy.i18ns)
Handlebars.registerHelper('translate', I18nEasy.translate)
Handlebars.registerHelper('translatePlural', I18nEasy.translatePlural)
Handlebars.registerHelper('i18nDefault', I18nEasy.i18nDefault)
Handlebars.registerHelper('ghost', -> ghostSuffix: '-ghost')

ironRouterPackage = 'iron-router'

if Package[ironRouterPackage]
	Handlebars.registerHelper(
		'pathToLanguage'
		(language)->
			try
				Package[ironRouterPackage].Router.current().route.path(language: language)
			catch error
				Meteor._debug """
				Warning: #{error.message}
				 |_route: #{Package[ironRouterPackage].Router.current().route.name}
				 |_path: #{Package[ironRouterPackage].Router.current().path}
				 |_template: #{Package[ironRouterPackage].Router.current().template}
				 |_language: #{language}
				"""
				"/#{language}"
	)
else
	Meteor._debug 'To benefit from the "pathToLanguage" helper you need to install "iron-router" smart package (https://atmosphere.meteor.com/package/iron-router)'