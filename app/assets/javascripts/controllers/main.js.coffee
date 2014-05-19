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

]
