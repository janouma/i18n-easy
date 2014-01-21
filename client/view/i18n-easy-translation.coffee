templateName = 'i18n-easy-translation'

Template[templateName].created =->
	@_context = new Context
	do @_context.init

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

		###DEBUG
		Meteor._debug "delete '#{$(e.target).parents('div[data-key]').attr 'data-key'}'"
		do template._context.reset
		template._context.set {
			status: 'warning'
			submitMessage: "DEBUG: Next step, the removal of '#{$(e.target).parents('div[data-key]').attr 'data-key'}' !!!"
		}
		do template._context.save###

		###
		key = $(e.target).parents('div[data-key]').attr 'data-key'
		Meteor.call(
			'i18nEasyRemoveKey'
			key
			(error)-> # TODO delete key
		)
		###
}