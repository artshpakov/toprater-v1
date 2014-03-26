@rating.controller "rating.MainCtrl", ["$scope", "Criterion", "Alternative", ($scope, Criterion, Alternative) ->

  $scope.alternatives = Alternative
  $scope.criteria     = Criterion

  $scope.toggle_criteria = ->
    $scope.criteria_shown = !$scope.criteria_shown
    $scope.properties_shown = false if $scope.criteria_shown

  $scope.toggle_properties = ->
    $scope.properties_shown = !$scope.properties_shown
    $scope.criteria_shown = false if $scope.properties_shown

]
