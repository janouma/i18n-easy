Template.i18n_easy_side_nav.events {
	'click .upload-link': (e, template)->
		do e.stopPropagation

		return if template._processing

		Meteor.clearTimeout template._toast
		$uploadForm = $(template.find '.upload-form')
		$uploadIcon = $(template.find '.upload-icon')
		offset = $uploadIcon.offset()

		$uploadForm.offset(
			top: offset.top + $uploadIcon.height()
			left: offset.left - $uploadForm.width()/2 + 8
		).removeClass 'hidden'

		$(template.find '.upload-input').removeAttr 'disabled'
		$(template.find '.upload-button').removeAttr 'disabled'

		template._toast = Meteor.setTimeout(
			-> $uploadForm.addClass 'hidden'
			5000
		)

	#==================================
	'mouseleave .upload-form': (e, template)->
		Meteor.clearTimeout template._toast

		template._toast = Meteor.setTimeout(
			-> $(e.target).addClass 'hidden'
			5000
		)

	#==================================
	'mouseenter .upload-form': (e, template)-> Meteor.clearTimeout template._toast

	#==================================
	'click .upload-form': (e)-> do e.stopPropagation

	#==================================
	'change .upload-input': (e, template) ->
		do e.preventDefault

		$(template.find '.upload-form').addClass 'hidden'

		input = e.target

		if not input.files.length
			Alert.warning 'nothingToSave'
			return

		file = input.files[0]

		$link = $(template.find '.upload-link')
		busyLinkClass = 'disabled'
		busyLinkColor = 'color-ash'

		$icon = $(template.find '.upload-icon')
		iddleIconClass = 'fa-upload'
		busyIconClass = 'fa-gear fa-spin'

		if file.type is 'application/json'
			reader = new FileReader

			reader.onload = ->
				try
					translations = JSON.parse @result
				catch error
					$icon.removeClass(busyIconClass).addClass(iddleIconClass)
					$link.removeClass(busyLinkClass).parent().removeClass(busyLinkColor)
					template._processing = no

					Meteor._debug error
					Alert.error 'wrongFileType'

				if translations
					Meteor.call(
						'I18nEasyImport'
						@result
						(error)->
							if error
								Alert.error 'internalServerError'
							else
								Alert.success 'successful'

							$icon.removeClass(busyIconClass).addClass(iddleIconClass)
							$link.removeClass(busyLinkClass).parent().removeClass(busyLinkColor)
							template._processing = no
					)

			reader.onerror = (error)->
				Meteor._debug error
				Alert.error 'unknownerror'
				$icon.removeClass(busyIconClass).addClass(iddleIconClass)
				$link.removeClass(busyLinkClass).parent().removeClass(busyLinkColor)
				template._processing = no

			reader.readAsText file
			template._processing = yes
			Alert.info 'processing'
			$icon.removeClass(iddleIconClass).addClass(busyIconClass)
			$link.addClass(busyLinkClass).parent().addClass(busyLinkColor)
		else
			Alert.error 'wrongFileType'

		do template.find('#input-wrapper').reset
}