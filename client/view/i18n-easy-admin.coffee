Template['i18n-easy-admin'].events {
    'submit form': (e)->
        do e.preventDefault


    'click #add': (e)->
        do e.preventDefault

        $newKeyInput = $('#newKey')
        newKey = $newKeyInput.val()
        #$newKeyInput.addClass('theme-redlight') unless $.trim(newKey)


    'input #newKey': (e)->
        $addButton = $('#add')

        if $(e.target).val().trim()
            $addButton.removeAttr('disabled').addClass('active-button theme-black color-grey').removeClass('theme-grey color-white')
        else
            $addButton.attr(disabled: yes).addClass('theme-grey color-white').removeClass('active-button theme-black color-grey')
}