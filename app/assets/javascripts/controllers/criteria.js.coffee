@rating.controller "rating.CriteriaCtrl", ["$scope", "Alternative", ($scope, Alternative) ->

  $scope.toggle_section = (criterion) ->
    $scope.active_section = if $scope.active_section and $scope.active_section is criterion then null else criterion

  $scope.$watch 'criteria.active.length', (active_criteria_count) ->
    if active_criteria_count
      Alternative.rate($scope.criteria.active).then (response) ->
        $scope.$parent.alternatives = response.data

]
