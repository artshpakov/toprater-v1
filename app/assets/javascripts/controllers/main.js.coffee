@rating.controller "rating.MainCtrl", ["$scope", "CriteriaCollection", "Alternative", ($scope, CriteriaCollection, Alternative) ->

  $scope.criteria = CriteriaCollection.all()
  $scope.active_criteria = []

  $scope.is_active = (criterion) ->
    criterion in $scope.active_criteria

  $scope.toggle_active = (criterion) ->
    if $scope.is_active(criterion)
      $scope.active_criteria = _.reject $scope.active_criteria, (c) -> c is criterion
    else
      $scope.active_criteria.push criterion

  $scope.$watch 'active_criteria.length', ->
    if $scope.active_criteria.length
      Alternative.rate(criteria: $scope.active_criteria).then (alternatives) ->
        $scope.alternatives = alternatives

]
