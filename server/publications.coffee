Meteor.publish(
    I18nBase.LANGUAGES_PUBLICATION
    ->
        I18nEasyMessages.find(
            {}
            {fields: language: yes}
        )
)