@rating.controller "rating.DetailsCtrl", ["$scope", "$routeParams", "Alternative", ($scope, $routeParams, Alternative) ->

  Alternative.pick($routeParams.id, $scope.criteria.active).then (alternative) ->
    $scope.alternative = alternative

]
