@rating.controller "rating.MainCtrl", ["$scope", "Search", "Criterion", "Alternative", "Property", "locale", ($scope, Search, Criterion, Alternative, Property, locale) ->

  $scope.search       = Search

  $scope.alternatives = Alternative
  $scope.criteria     = Criterion
  $scope.properties   = Property

  $scope.locale       = locale

]
