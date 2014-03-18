@rating.controller "rating.CriteriaCtrl", ["$scope", ($scope) ->

  $scope.toggle_section = (criterion) ->
    $scope.active_section = if $scope.active_section and $scope.active_section is criterion then null else criterion
]
