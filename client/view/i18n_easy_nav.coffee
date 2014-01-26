templateName = 'i18n_easy_nav'

Template[templateName].helpers(
    activeLanguageClass: (language)-> 'active' if language is I18nEasy.getLanguage()
    activeFlagClass: (language)-> if language is I18nEasy.getLanguage() then 'fa-flag' else 'fa-flag-o'
    languages: -> do I18nEasy.getLanguages
)

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

}