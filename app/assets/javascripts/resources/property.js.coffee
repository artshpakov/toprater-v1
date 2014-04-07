@rating.factory 'Property', ["$resource", "data", "Search", ($resource, data, Search) ->

  _.tap $resource('/properties/:id', { id: '@id' }), (Property) ->

    Property::type = 'property'

    cache   = _.map data.properties, (params) -> new Property params
    picked  = []

    Property.all    = cache
    Property.picked = picked

    Property::is_picked = -> @ in picked

    Property::pick = ->
      Search.items.push @ unless @is_picked()
    Property::drop = ->
      Search.items.splice picked.indexOf(@), 1
    Property::toggle = ->
      if @is_picked() then @drop() else pick()

]
