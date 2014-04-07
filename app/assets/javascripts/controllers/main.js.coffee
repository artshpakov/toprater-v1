@rating.controller "rating.MainCtrl", ["$scope", "Criterion", "Alternative", "Property", "locale", ($scope, Criterion, Alternative, Property, locale) ->

  $scope.alternatives = Alternative
  $scope.criteria     = Criterion
  $scope.properties   = Property

  $scope.locale       = locale

]
