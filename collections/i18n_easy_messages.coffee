@I18nEasyMessages = new Meteor.Collection 'i18n_easy_messages'

permissions =
    insert: -> yes
    update: -> yes

@I18nEasyMessages.allow permissions

Meteor.methods {
	i18nEasyAddKey: (newKey)->
		check newKey, String

		if I18nEasyMessages.find(key: new RegExp("^#{newKey}$",'i')).count()
			throw new Meteor.Error 409, "duplicated key '#{newKey}'"
		else
			I18nEasyMessages.insert(
				key: newKey
				language: I18nEasy.getDefault()
				message: ''
			)
}