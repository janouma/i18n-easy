Router.map ->
	@route(
		'i18n_easy_admin'
		where: 'client'
		path: '/:language?/i18n-easy-admin'
		layoutTemplate: 'i18n_easy_layout'

		before: ->
			language = @params.language

			if language and I18nEasy.getLanguage() isnt language
				I18nEasy.setLanguage language

		waitOn: -> [
			I18nEasy.defaultSubscribe()

			Meteor.subscribe(
				I18nBase.TRANSLATION_PUBLICATION
				default: I18nEasy.getDefault()
				actual: I18nEasy.getDefault()
			)
		]
	)

	@route(
		'i18n_easy_translations'
		where: 'server'
		path: '/i18n-easy-translations'
		action: ->
			@response.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'

			translations = {}
			I18nEasyMessages.find(
				{}
				sort:
					language: 1
					key: 1
			).forEach (document)->
				if document.language?.length and document.key?.length and document.message?.length
					language = translations[document.language] ?= {}
					language[document.key] = document.message

			@response.write JSON.stringify(translations)
			do @response.end
	)
