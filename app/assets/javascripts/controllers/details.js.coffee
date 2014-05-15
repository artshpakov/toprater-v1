@rating.controller "rating.DetailsCtrl", ["$scope", "$routeParams", "Alternative", "Search", ($scope, $routeParams, Alternative, Search) ->

  Alternative.pick($routeParams.id).then (alternative) ->
    $scope.current_alternative = alternative

  $scope.realm = $routeParams.realm

]
