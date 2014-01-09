Template['i18n-easy-admin'].helpers(
    keys: ->
        results = I18nEasyMessages.find(
            {}
            {
                fields: key: yes
                sort: key: 1
            }
        ).fetch()
        
        distinctKeys = []
        distinctKeys.push result.key for result in results when result.key not in distinctKeys
        distinctKeys
)