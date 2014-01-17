Template['i18n-easy-translation'].events {
	#==================================
	'focus div[id^=translation_] textarea': (e)-> $(e.target).parents('div[id^=translation_]').find('textarea').addClass 'focus'

	#==================================
	'blur div[id^=translation_] textarea': (e)-> $(e.target).parents('div[id^=translation_]').find('textarea').removeClass 'focus'
}