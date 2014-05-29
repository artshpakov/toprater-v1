@rating.controller "rating.MainCtrl", ["$scope", "data", "Search", "Criterion", "Alternative", "Property", "locale", ($scope, data, Search, Criterion, Alternative, Property, locale) ->

  $scope.search       = Search

  $scope.alternatives = Alternative
  $scope.criteria     = Criterion
  $scope.properties   = Property

  $scope.locale       = locale
  $scope.realms       = data.realms
  
  calculate_columns_count = -> if $scope.filters_shown then 4 else 5
  $scope.cards_in_row = calculate_columns_count()
  $scope.$watch 'filters_shown', ->
    $scope.cards_in_row = calculate_columns_count()
  $scope.toggle_filters = ->
    $scope.filters_shown = !$scope.filters_shown

  $scope.range        = _.range


  $scope.popup_shown = false
  $scope.toggle_popup = ->
    $scope.popup_shown = !$scope.popup_shown

  $scope.StaticFilters = {
    list: [
      { id: window.rating_data.stars_property_id, type: 'static_filter', name: 'stars', value: null, values: [2,3,4,5], active: false },
      { id: 'country_name', type: 'static_filter', name: 'country', value: null, values: window.rating_data.country_names }
    ]

    get         : (name) -> _.findWhere(@list, name: name)

    is_selected : (filter_type, value) -> Search.is_picked @get(filter_type), value

    pick        : (type, value) ->
      if _.isString(value) && _.size(value) == 0
        value = null

      filter_object = @get(type)

      if value == filter_object.value
        filter_object.value = null
        Search.drop(filter_object)
      else
        if Search.is_picked(filter_object)
          Search.drop(filter_object)

        filter_object.value = value
        Search.pick filter_object, true, true
  }

]
