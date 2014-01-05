Meteor.methods(
    clearI18nEasyMessages: ->
        Meteor._debug "Clearing 'i18n_easy_messages' collection for test purpose"
        I18nEasyMessages.remove {}
)