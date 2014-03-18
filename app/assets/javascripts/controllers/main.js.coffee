@rating.controller "rating.MainCtrl", ["$scope", "CriteriaCollection", "AlternativesCollection", ($scope, CriteriaCollection, AlternativesCollection) ->

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
    if promise = AlternativesCollection.rate($scope.active_criteria)
      promise.then (response) ->
        $scope.alternatives = response.data

]
