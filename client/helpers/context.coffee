class @Context
	sessionPrefix = 'i18n-easy-submit-result'
	sessionPropertyPattern = /^_\w+$/

	@varNameFor: (property)-> "#{sessionPrefix}_#{property}"

	save: -> Session.set("#{sessionPrefix}#{property}", value) for own property, value of @ when sessionPropertyPattern.test property

	clear: -> @[property] = undefined for own property, value of @ when sessionPropertyPattern.test property

	reset: ->
		do @clear
		do @save

	init: -> do @reset

	set: (newContext)->
		@displayedPath = Router.current().path
		@["_#{property}"] = value for own property, value of newContext

	get: (property)-> @["_#{property}"]