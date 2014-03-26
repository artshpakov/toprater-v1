@rating.controller "rating.MainCtrl", ["$scope", "Criterion", "Alternative", ($scope, Criterion, Alternative) ->

  $scope.alternatives = Alternative
  $scope.criteria     = Criterion

]
