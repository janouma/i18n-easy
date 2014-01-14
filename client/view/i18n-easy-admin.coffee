context =
	sessionPrefix: 'i18n-easy-submit-result'
	sessionPropertyPattern: /^_\w+$/

	update: -> Session.set("#{@sessionPrefix}#{property}", value) for property, value of @ when @sessionPropertyPattern.test property

	clear: ->
		@_submitMessage = undefined
		@_statusClass = undefined
		@_displayClass = 'hidden'
		@_disabledClass = 'theme-grey color-white'
		@_disabledAttr = 'disabled'

	reset: ->
		do @clear
		do @update

	init: -> do @reset


templateName = 'i18n-easy-admin'

Template[templateName].created =-> do context.init


Template[templateName].helpers {
	emptyWarningClass: (translation)-> 'theme-redlight color-redlight' unless translation?.length
	displayClass: -> Session.get "#{context.sessionPrefix}_displayClass"
	submitMessage: -> Session.get "#{context.sessionPrefix}_submitMessage"
	statusClass: -> Session.get "#{context.sessionPrefix}_statusClass"
	disabledClass: -> Session.get "#{context.sessionPrefix}_disabledClass"
	disabledAttr: -> Session.get "#{context.sessionPrefix}_disabledAttr"
}


Template[templateName].events {

	'submit form': (e)->
		do e.preventDefault


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
					context._submitMessage = I18nEasy.i18nDefault(if error.error is 409 then 'duplicatedKey' else 'internalServerError')
					context._statusClass = 'theme-redlight color-redlight'
				else
					$newKeyInput.val ''
					context._submitMessage = I18nEasy.i18nDefault 'successful'
					context._statusClass = 'theme-jade color-emerald'

					Meteor.setTimeout(
						-> do context.reset
						3000
					)

				do context.update
		)


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