@rating.controller "rating.PropertiesCtrl", ["$scope", "data", "Alternative", ($scope, data, Alternative) ->

  $scope.properties = data.properties
  $scope.filters = []

  $scope.apply = ->
    Alternative.rate(filters: $scope.filters).then (alternatives) ->
      if alternatives.length
        $scope.$parent.alternatives = alternatives
      else
        $scope.nothing_found = 'Nothing found'


]
