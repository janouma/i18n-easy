context =
	sessionPrefix: 'i18n-easy-submit-result'

	update: ->
		sessionPropertyPattern = /^_\w+$/
		Session.set("#{@sessionPrefix}#{property}", value) for property, value of @ when sessionPropertyPattern.test property

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

				if error
					Meteor._debug error
					context._displayClass = undefined
					context._submitMessage = I18nEasy.i18nDefault(if error.error is 409 then 'duplicatedKey' else 'internalServerError')
					context._statusClass = 'theme-redlight color-redlight'
					context._disabledClass = 'theme-grey color-white'
					context._disabledAttr = 'disabled'
				else
					$newKeyInput.val ''
					do context.clear

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