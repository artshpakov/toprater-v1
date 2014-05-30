@rating.controller "rating.FiltersCtrl", ["$scope", "data", "Search", ($scope, data, Search) ->

  $scope.static_filters =
    items:
      country:
        id: 'country_name'
        type: 'static_filter'
        name: 'country'
        value: null
        values: data.country_names
      stars:
        id: data.stars_property_id
        type: 'static_filter'
        name: 'stars'
        value: null
        values: [2,3,4,5]
        active: false

    is_selected : (filter_type, value) -> Search.is_picked @items[filter_type], value
    
    pick        : (type, value) ->
      # for cases then value is one of the select option and prompt option is empty string :)
      if _.isString(value) && _.size(value) == 0
        value = null

      filter_object = @items[type]

      if value == filter_object.value
        filter_object.value = null
        Search.drop(filter_object)
      else
        if Search.is_picked(filter_object)
          Search.drop(filter_object)

        filter_object.value = value
        Search.pick filter_object, true, true

]
