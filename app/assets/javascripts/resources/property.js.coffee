@rating.factory 'Property', ["$resource", "data", ($resource, data) ->

  _.tap $resource('/properties/:id', { id: '@id' }), (Property) ->

    cache   = _.map data.properties, (params) -> new Property params
    picked  = []

    Property.all    = cache
    Property.picked = picked

    Property::is_picked = -> @ in picked

    Property::pick = ->
      picked.push @ unless @is_picked()
    Property::drop = ->
      picked.splice picked.indexOf(@), 1
    Property::toggle = ->
      if @is_picked() then @drop() else pick()

]
