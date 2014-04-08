@rating.factory 'Property', ["$resource", "data", ($resource, data) ->

  _.tap $resource('/properties/:id', { id: '@id' }), (Property) ->

    Property::type = 'property'

    cache = _.map data.properties, (params) -> new Property params

    Property::toggle = -> @active = !@active

    Property.all = cache

]
