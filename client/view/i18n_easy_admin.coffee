templateName = 'i18n_easy_admin'

Template[templateName].created =->
	@_context = new Context
	do @_context.init


Template[templateName].helpers {
	submitMessage: -> Session.get Context.varNameFor('submitMessage')
}


Template[templateName].events {

	'submit form': (e, template)->
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
			template._context.set {
				status: 'info'
				submitMessage: I18nEasy.i18nDefault 'processing'
			}
			do template._context.save

			Meteor.call(
				'i18nEasySave'
				translations
				(error)->
					if error
						template._context.set {
							status: 'error'
							submitMessage: I18nEasy.i18nDefault 'internalServerError'
						}
					else
						template._context.set {
							status: 'success'
							submitMessage: I18nEasy.i18nDefault 'successful'
						}

					do template._context.save
			)
		else
			do template._context.reset
			template._context.set {
				status: 'warning'
				submitMessage: I18nEasy.i18nDefault 'nothingToSave'
			}
			do template._context.save


	#==================================
	'click #add': (e, template)->
		do e.preventDefault

		$newKeyInput = $('#newKey')

		template._context.set {
			status: 'info'
			submitMessage: I18nEasy.i18nDefault 'processing'
		}
		do template._context.save

		Meteor.call(
			'i18nEasyAddKey'
			$.trim $newKeyInput.val()
			(error)->
				if error
					template._context.set {
						status: 'error'
						submitMessage: I18nEasy.i18nDefault(if error.error is 409 then 'duplicatedKey' else 'internalServerError')
					}
				else
					template._context.set {
						status: 'success'
						submitMessage: I18nEasy.i18nDefault 'successful'
					}

				do template._context.save
		)

	#==================================
	'input #newKey': (e, template)->
		$addButton = $('#add')

		if /^\w+$/.test $(e.target).val().trim()
			$addButton.removeAttr('disabled')
				.addClass('active-button theme-black color-lightmagenta')
				.removeClass('theme-grey color-smoke')
		else
			$addButton.attr(disabled: yes)
				.addClass('theme-grey color-smoke')
				.removeClass('active-button theme-black color-lightmagenta')
}


Template[templateName].rendered = ->
	return unless @_context.get('submitMessage')

	Meteor.clearTimeout @_context.toast
	$messageElts = $('#submit-result, #submit-note')

	showMessage = =>
		statusClasses =
			info: 'theme-blue color-black'
			success: 'theme-emerald color-black'
			warning: 'theme-gold color-black'
			error: 'theme-redlight color-black'

		if @_context.get 'status'
			$messageElts.addClass(statusClasses[@_context.get 'status'])
			.removeClass 'hidden'

		$('#add').addClass('theme-grey color-smoke')
		.removeClass('active-button theme-black color-lightmagenta')
		.attr disabled: yes

		$('#newKey').val('') if @_context.get('status') is 'success'

	if @_context.displayedPath is Router.current().path
		Meteor.defer showMessage
	else
		showMessage()

	@_context.toast = Meteor.setTimeout(
		=>
			do @_context.clear
			$messageElts.addClass 'hidden'

		5000
	)