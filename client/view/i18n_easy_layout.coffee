Template.i18n_easy_layout.events {
	'click .i18n-easy': (e, template)->
		fadeUploadForm(
			$(template.find '.upload-form')
			template
		)
}