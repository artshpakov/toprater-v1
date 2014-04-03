@rating.controller "rating.MainCtrl", ["$scope", "Criterion", "Alternative", "Property", "locale", ($scope, Criterion, Alternative, Property, locale) ->

  $scope.alternatives = Alternative
  $scope.criteria     = Criterion
  $scope.properties   = Property

  $scope.locale       = locale

  $scope.toggle_properties = ->
    $scope.properties_shown = !$scope.properties_shown

]
