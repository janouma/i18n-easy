Template['i18n-easy-nav'].helpers(
    activeRouteClass: (language)-> 'active' if language is I18nEasy.getLanguage()
    languages: -> do I18nEasy.getLanguages
)