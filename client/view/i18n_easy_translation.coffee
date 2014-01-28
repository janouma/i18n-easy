templateName = 'i18n_easy_translation'

Template[templateName].helpers {
	emptyWarningClass: (translation)-> 'label theme-gold color-black' unless translation?.length
}


Template[templateName].events {

	'focus div[id^=translation_] textarea': (e)-> $(e.target).parents('div[id^=translation_]').find('textarea').addClass 'focus'

	#==================================
	'blur div[id^=translation_] textarea': (e)-> $(e.target).parents('div[id^=translation_]').find('textarea').removeClass 'focus'

	#==================================
	'click .delete': (e, template)->
		Meteor.clearTimeout template._toast

		$ask = $(template.find('.ask')).removeClass 'hidden'
		template._cancel = no

		template._toast = Meteor.setTimeout(
			->
				template._cancel = yes
				$ask.addClass 'hidden'
			5000
		)

	#==================================
	'click .cancel': (e, template)->
		do e.preventDefault
		template._cancel = yes
		Meteor.clearTimeout template._toast
		$(template.find '.ask').addClass 'hidden'


	#==================================
	'click .confirm': (e, template)->
		do e.preventDefault
		return if template._cancel

		$(template.find '.ask').addClass 'hidden'

		Meteor.call(
			'i18nEasyRemoveKey'
			$(template.find 'div[data-key]').attr('data-key')

			(error)->
				if error
					Alert.error 'internalServerError'
				else
					Alert.success 'successful'
		)
}