@rating.controller "rating.RatingCtrl", ["$scope", "Alternative", ($scope, Alternative) ->

  $scope.pick = (alternative) ->
    $scope.current_alternative = alternative

  $scope.belongs_here = (index) ->
    0 <= index - Alternative.all.indexOf($scope.current_alternative) < 3

  $scope.has_previous = ->
    $scope.current_alternative? and $scope.current_alternative.index() > 0
  $scope.has_next     = ->
    $scope.current_alternative? and $scope.current_alternative.index() < Alternative.all.length-1 
  $scope.previous     = ->
    $scope.current_alternative = Alternative.all[$scope.current_alternative.index()-1]
  $scope.next         = ->
    $scope.current_alternative = Alternative.all[$scope.current_alternative.index()+1]

]
