@rating.controller "rating.DetailsCtrl", ["$scope", "$routeParams", "Alternative", ($scope, $routeParams, Alternative) ->

  Alternative.pick($routeParams.id, $scope.active_criteria).then (alternative) ->
    $scope.alternative = alternative

]
