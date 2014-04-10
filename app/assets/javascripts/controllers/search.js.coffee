@rating.controller "rating.SearchCtrl", ["$scope", "Criterion", "Property", "Search", ($scope, Criterion, Property, Search) ->

  $scope.$watch 'query', (query) ->
    if query
      Search.fetch { query }, (data) -> $scope.tips = data
    else
      $scope.reset_search()

  $scope.reset_search = ->
    _.defer -> $scope.tips = []

  $scope.pick_tip = (tip) ->
    entry = switch tip.type
      when 'criterion'
        _.find(Criterion.all, (criterion) -> criterion.id is tip.id)
      when 'property'
        _.find(Property.all, (property) -> property.id is tip.id)
    Search.pick entry
    $scope.query = null

]
