templateName = 'i18n_easy_nav'

Template[templateName].helpers {
    activeLanguageClass: (language)-> 'active' if language is I18nEasy.getLanguage()
    activeFlagClass: (language)-> if language is I18nEasy.getLanguage() then 'fa-flag' else 'fa-flag-o'

	languages: ->
		for language in I18nEasy.getLanguages()
			language: language
			notDefault: language isnt I18nEasy.getDefault()
}

Template[templateName].events {

	'input .new-language': (e, template)->
		$wrapper = $(template.find '.new-language-wrapper')
		activeClass = 'active'

		if /^\w{2}$/.test $(e.target).val().trim()
			$wrapper.addClass activeClass
		else
			$wrapper.removeClass activeClass

	#==================================
	'click .active .add-language': (e, template)->
		$newLanguage = $(template.find '.new-language')

		Meteor.call(
			'i18nEasyAddLanguage'
			$.trim $newLanguage.val()

			(error)->
				$newLanguage.val ''
				if error
					Alert.error(if error.error is 409 then 'duplicatedLanguage' else 'internalServerError')
				else
					Alert.success 'successful'
		)

	#==================================
	'click .delete': (e, template)->
		do e.preventDefault

		Meteor.clearTimeout template._toast
		$ask = $(template.find '.ask')
		$delete = $(e.target)
		offset = $ask.offset()

		$ask.offset(
			top: offset.top
			left: $delete.siblings('.language-icon').offset().left - $ask.width()/2 + 9
		).removeClass 'hidden'

		template._targetedLanguage = $delete.attr('data-language')
		template._cancel = no

		template._toast = Meteor.setTimeout(
			->
				template._targetedLanguage = undefined
				template._cancel = yes
				$ask.addClass 'hidden'
			5000
		)


	#==================================
	'click .cancel': (e, template)->
		do e.preventDefault

		template._targetedLanguage = undefined
		template._cancel = yes
		Meteor.clearTimeout template._toast
		$(template.find('.ask')).addClass 'hidden'


	#==================================
	'click .confirm': (e, template)->
		do e.preventDefault
		return if template._cancel

		$(template.find '.ask').addClass 'hidden'

		if template._targetedLanguage
			Meteor.call(
				'i18nEasyRemoveLanguage'
				template._targetedLanguage

				(error)->
					if error
						Alert.error 'internalServerError'
					else
						Alert.success 'successful'

						if template._targetedLanguage is I18nEasy.getLanguage()
							Router.go(
								'i18n_easy_admin'
								language: I18nEasy.getDefault()
							)

						template._targetedLanguage = undefined
			)

}