@rating.controller "rating.CriteriaCtrl", ["$scope", ($scope) ->

  $scope.make_section_active = (criterion) ->
    $scope.active_section = criterion
]
