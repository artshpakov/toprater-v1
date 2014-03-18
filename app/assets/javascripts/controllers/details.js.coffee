@rating.controller "rating.DetailsCtrl", ["$scope", "$routeParams", "Alternative", ($scope, $routeParams, Alternative) ->

  Alternative.get id: $routeParams.id, (alternative) ->
    $scope.alternative = alternative

]
