@rating.controller "rating.CriteriaCtrl", ["$scope", "Alternative", ($scope, Alternative) ->

  $scope.toggle_section = (criterion) ->
    $scope.active_section = if $scope.active_section and $scope.active_section is criterion then null else criterion

  $scope.$watch 'criteria.active.length', (criteria_count) ->
    Alternative.rate()

]
