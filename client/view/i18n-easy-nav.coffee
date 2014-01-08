Template['i18n-easy-nav'].helpers(
    activeRouteClass: (routeNames...)->
        activeRoutePattern = new RegExp "^(\w{2}\/)?#{Router.current().route.name}\/?"
        # routeNames[0...] gets rid of the hash added by handlebars
        return 'active' for route in routeNames[0...] when activeRoutePattern.test route
    
    languages: -> do I18nEasy.getLanguages
)