context =
	sessionPrefix: 'i18n-easy-submit-result'
	sessionPropertyPattern: /^_\w+$/

	update: ->
		Session.set("#{@sessionPrefix}#{property}", value) for property, value of @ when @sessionPropertyPattern.test property

	clear: ->
		@_submitMessage = undefined
		@_statusClass = undefined
		@_displayClass = 'hidden'
		@_disabledClass = 'theme-grey color-white'
		@_disabledAttr = 'disabled'

	reset: ->
		do @clear
		do @update

	init: ->
		do @reset

	flash: (newContext)->
		@["_#{property}"] = value for property, value of newContext
		do @update
		Meteor.setTimeout(
			=> do @reset
			5000
		)


templateName = 'i18n-easy-admin'

Template[templateName].created =-> do context.init


Template[templateName].helpers {
	emptyWarningClass: (translation)-> 'label theme-redlight color-black' unless translation?.length
	displayClass: -> Session.get "#{context.sessionPrefix}_displayClass"
	submitMessage: -> Session.get "#{context.sessionPrefix}_submitMessage"
	statusClass: -> Session.get "#{context.sessionPrefix}_statusClass"
	disabledClass: -> Session.get "#{context.sessionPrefix}_disabledClass"
	disabledAttr: -> Session.get "#{context.sessionPrefix}_disabledAttr"
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
					key: $singular.attr 'id'
					language: I18nEasy.getLanguage()
					message: message
				}

		if translations.length
			Meteor.call(
				'i18nEasySave'
				translations
				#callBack
			)
		else
			$('#newKey').val ''
			context.flash {
				displayClass: undefined
				disabledClass: 'theme-grey color-white'
				disabledAttr: 'disabled'
				submitMessage: I18nEasy.i18nDefault 'nothingToSave'
				statusClass: 'theme-emerald color-black'
			}

	#==================================
	'click #add': (e)->
		do e.preventDefault

		$newKeyInput = $('#newKey')

		Meteor.call(
			'i18nEasyAddKey'
			$.trim $newKeyInput.val()

			(error)->
				do context.reset
				context._displayClass = undefined
				context._disabledClass = 'theme-grey color-white'
				context._disabledAttr = 'disabled'

				if error
					context.flash {
						submitMessage: I18nEasy.i18nDefault(if error.error is 409 then 'duplicatedKey' else 'internalServerError')
						statusClass: 'theme-redlight color-black'
					}
				else
					$newKeyInput.val ''
					context.flash {
						submitMessage: I18nEasy.i18nDefault 'successful'
						statusClass: 'theme-emerald color-black'
					}
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