@rating.controller "rating.SearchCtrl", ["$scope", "Criterion", "Search", ($scope, Criterion, Search) ->

  $scope.$watch 'query', (query) ->
    if query
      Search.fetch query, (data) -> $scope.tips = data
    else
      $scope.reset_search()

  $scope.reset_search = ->
    _.defer -> $scope.tips = []

  $scope.pick_tip = (tip) ->
    _.find(Criterion.leafs, (criterion) -> criterion.id is tip.id).set_state 'active'
    $scope.query = null

]
