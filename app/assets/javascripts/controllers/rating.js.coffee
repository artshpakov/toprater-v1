@rating.controller "rating.RatingCtrl", ["$scope", "Alternative", ($scope, Alternative) ->

  $scope.pick = (alternative) ->
    $scope.current_alternative = alternative

  $scope.$watch 'current_alternative', (alternative) ->
    if alternative?
      _.defer ->
        element = document.getElementById "middle#{ $scope.row alternative.index() }"
        window.scrollTo 0, element.offsetTop - 70

  $scope.belongs_here = (index) ->
    $scope.current_alternative and 0 <= index - $scope.current_alternative.index() < 3
  $scope.last_in_row = (index) ->
    (index+1)%3 == 0 or index == Alternative.all.length-1

  $scope.has_previous = ->
    $scope.current_alternative? and $scope.current_alternative.index() > 0
  $scope.has_next     = ->
    $scope.current_alternative? and $scope.current_alternative.index() < Alternative.all.length-1 
  $scope.previous     = ->
    $scope.current_alternative = Alternative.all[$scope.current_alternative.index()-1]
  $scope.next         = ->
    $scope.current_alternative = Alternative.all[$scope.current_alternative.index()+1]

  $scope.row = (index) -> Math.floor index/3

]
