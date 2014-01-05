@I18nEasyMessages = new Meteor.Collection 'i18n_easy_messages'

permissions =
    insert: -> yes
    update: -> yes

@I18nEasyMessages.allow permissions

Meteor.methods(
    clearI18nEasyMessages: -> I18nEasyMessages.remove {}
)