context =
	sessionPrefix: 'i18n-easy-submit-result'
	sessionPropertyPattern: /^_\w+$/

	save: -> Session.set("#{@sessionPrefix}#{property}", value) for property, value of @ when @sessionPropertyPattern.test property

	clear: -> @[property] = undefined for property, value of @ when @sessionPropertyPattern.test property

	reset: ->
		do @clear
		do @save

	init: -> do @reset

	set: (newContext)-> @["_#{property}"] = value for property, value of newContext

	get: (property)-> @["_#{property}"]
	varNameFor: (property)-> "#{@sessionPrefix}_#{property}"


templateName = 'i18n-easy-admin'

Template[templateName].created =-> do context.init


Template[templateName].helpers {
	emptyWarningClass: (translation)-> 'label theme-gold color-black' unless translation?.length
	submitMessage: -> Session.get context.varNameFor('submitMessage')
}


Template[templateName].events {

	'submit form': (e)->
		do e.preventDefault

		translations = []

		$('[id^=translation_]').each ->
			message = undefined

			$singular = $(@).find '[name=singular]'
			singularValue = $.trim $singular.val()

			$plural = $(@).find '[name=plural]'
			pluralValue = $.trim $plural.val()

			if pluralValue isnt $plural.attr('data-initial-value')
				message = [singularValue, pluralValue]
			else
				message = singularValue if singularValue isnt $singular.attr('data-initial-value')

			if message
				translations.push {
					key: $(@).attr 'data-key'
					language: I18nEasy.getLanguage()
					message: message
				}

		if translations.length
			context.set {
				status: 'info'
				submitMessage: I18nEasy.i18nDefault 'processing'
			}
			do context.save

			Meteor.call(
				'i18nEasySave'
				translations
				(error)->
					if error
						context.set {
							status: 'error'
							submitMessage: I18nEasy.i18nDefault 'internalServerError'
						}
					else
						context.set {
							status: 'success'
							submitMessage: I18nEasy.i18nDefault 'successful'
						}

					do context.save
			)
		else
			do context.reset
			context.set {
				status: 'warning'
				submitMessage: I18nEasy.i18nDefault 'nothingToSave'
			}
			do context.save

	#==================================
	'click #add': (e)->
		do e.preventDefault

		$newKeyInput = $('#newKey')

		context.set {
			status: 'info'
			submitMessage: I18nEasy.i18nDefault 'processing'
		}
		do context.save

		Meteor.call(
			'i18nEasyAddKey'
			$.trim $newKeyInput.val()
			(error)->
				if error
					context.set {
						status: 'error'
						submitMessage: I18nEasy.i18nDefault(if error.error is 409 then 'duplicatedKey' else 'internalServerError')
					}
				else
					context.set {
						status: 'success'
						submitMessage: I18nEasy.i18nDefault 'successful'
					}

				do context.save
		)

	#==================================
	'input #newKey': (e)->
		$addButton = $('#add')

		if /^\w+$/.test $(e.target).val().trim()
			$addButton.removeAttr('disabled')
				.addClass('active-button theme-black color-grey')
				.removeClass('theme-grey color-white')
		else
			$addButton.attr(disabled: yes)
				.addClass('theme-grey color-white')
				.removeClass('active-button theme-black color-grey')
}


Template[templateName].rendered = ->
	return unless context.get('submitMessage')

	Meteor.clearTimeout context.toast
	$messageElts = $('#submit-result, #submit-note')

	Meteor.defer ->
		statusClasses =
			info: 'theme-blue color-black'
			success: 'theme-emerald color-black'
			warning: 'theme-gold color-black'
			error: 'theme-redlight color-black'

		if context.get 'status'
			$messageElts.addClass(statusClasses[context.get 'status'])
				.removeClass 'hidden'

		$('#add').addClass('theme-grey color-white')
			.removeClass('active-button theme-black color-grey')
			.attr disabled: yes

		$('#newKey').val('') if context.get('status') is 'success'

	context.toast = Meteor.setTimeout(
		->
			do context.clear
			$messageElts.addClass 'hidden'

		5000
	)