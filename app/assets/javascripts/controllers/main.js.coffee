@rating.controller "rating.MainCtrl", ["$scope", "data", "Search", "Criterion", "Alternative", "Property", "locale", ($scope, data, Search, Criterion, Alternative, Property, locale) ->

  $scope.search       = Search

  $scope.alternatives = Alternative
  $scope.criteria     = Criterion
  $scope.properties   = Property

  $scope.locale       = locale
  $scope.realms       = data.realms
  
  $scope.cards_in_row = 5

  $scope.range        = _.range

]
