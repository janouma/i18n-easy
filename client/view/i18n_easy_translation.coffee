templateName = 'i18n_easy_translation'

Template[templateName].helpers {
	emptyWarningClass: (translation)-> 'label theme-gold color-black' unless translation?.length
}


Template[templateName].events {
	#==================================
	'focus div[id^=translation_] textarea': (e)-> $(e.target).parents('div[id^=translation_]').find('textarea').addClass 'focus'

	#==================================
	'blur div[id^=translation_] textarea': (e)-> $(e.target).parents('div[id^=translation_]').find('textarea').removeClass 'focus'

	#==================================
	'click .delete': (e, template)->
		do e.preventDefault
		Meteor.clearTimeout template._toast

		$confirm = $(template.find('.confirm')).removeClass 'hidden'

		template._toast = Meteor.setInterval(
			-> $confirm.addClass 'hidden'
			5000
		)

	#==================================
	'click .confirm': (e, template)->
		do e.preventDefault

		$confirm = $(template.find('.confirm')).addClass 'hidden'

		Meteor.call(
			'i18nEasyRemoveKey'
			$confirm.parents('div[data-key]').attr('data-key')

			(error)->
				if error
					Alert.error 'internalServerError'
				else
					Alert.success 'successful'
		)
}