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
	'click .active .add-language': (e)->
		Meteor._debug "add language"

}