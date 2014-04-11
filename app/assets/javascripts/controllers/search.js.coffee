@rating.controller "rating.SearchCtrl", ["$scope", "$location", "$routeParams", "Criterion", "Property", "Search", ($scope, $location, $routeParams, Criterion, Property, Search) ->

  $scope.$watch 'query', (query) ->
    if query
      Search.query { q: query }, (data) -> $scope.tips = data
    else
      $scope.reset_search()

  $scope.reset_search = ->
    _.defer -> $scope.tips = []

  $scope.pick_tip = (tip) ->
    switch tip.type
      when 'criterion'
        Search.pick _.find(Criterion.all, (criterion) -> criterion.id is tip.id)
      when 'property'
        Search.pick _.find(Property.all, (property) -> property.id is tip.id)
      when 'alternative'
        $location.path "/#{ $scope.locale }/#{ $routeParams.realm }/alternatives/#{ tip.id }"
    $scope.query = null

]
