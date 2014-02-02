Template.i18n_easy_side_nav.events {
	'click .upload-link': (e, template)->
		do e.stopPropagation

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
			-> fadeUploadForm $uploadForm, template
			5000
		)

	#==================================
	'mouseleave .upload-form': (e, template)->
		Meteor.clearTimeout template._toast

		template._toast = Meteor.setTimeout(
			-> fadeUploadForm $(e.target), template
			5000
		)

	#==================================
	'mouseenter .upload-form': (e, template)-> Meteor.clearTimeout template._toast

	#==================================
	'click .upload-form': (e)-> do e.stopPropagation
}