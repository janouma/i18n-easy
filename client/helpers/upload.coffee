@fadeUploadForm = ($form, template)->
	$(template.find '.upload-input').attr disabled: yes
	$(template.find '.upload-button').attr disabled: yes
	$form.addClass 'hidden'