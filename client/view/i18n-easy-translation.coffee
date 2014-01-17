templateName = 'i18n-easy-translation'

Template[templateName].helpers {
	emptyWarningClass: (translation)-> 'label theme-gold color-black' unless translation?.length
}


Template[templateName].events {
	#==================================
	'focus div[id^=translation_] textarea': (e)-> $(e.target).parents('div[id^=translation_]').find('textarea').addClass 'focus'

	#==================================
	'blur div[id^=translation_] textarea': (e)-> $(e.target).parents('div[id^=translation_]').find('textarea').removeClass 'focus'
}