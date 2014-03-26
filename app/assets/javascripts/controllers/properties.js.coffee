@rating.controller "rating.PropertiesCtrl", ["$scope", "Property", "Alternative", ($scope, Property, Alternative) ->

  $scope.properties = Property.all
  $scope.active_properties = Property.active

  $scope.apply = ->
    Alternative.rate().then (alternatives) ->
      $scope.toggle_properties()

  $scope.update_filters = -> $scope.dirty = true
  $scope.$watch 'dirty', (dirty) ->
    if dirty
      _.defer -> Alternative.count().then (response) ->
        $scope.filtered_alternatives_count = response.count
        $scope.dirty = false

]
