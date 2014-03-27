@rating.controller "rating.RatingCtrl", ["$scope", "Alternative", ($scope, Alternative) ->

  $scope.current_alternative = Alternative.current_alternative

  $scope.pick = (alternative) ->
    $scope.current_alternative = Alternative.current_alternative = alternative

  $scope.scroll_to = (alternative) ->
    _.defer ->
      element = document.getElementById "middle#{ $scope.row alternative.index() }"
      window.scrollTo 0, element.offsetTop - 70

  $scope.$watch 'current_alternative', (alternative) ->
    $scope.scroll_to alternative if alternative?

  console.log $scope.current_alternative
  $scope.scroll_to $scope.current_alternative if $scope.current_alternative?


  $scope.belongs_here = (index) ->
    $scope.current_alternative and 0 <= index - $scope.current_alternative.index() < 3
  $scope.last_in_row = (index) ->
    (index+1)%3 == 0 or index == Alternative.all.length-1

  $scope.has_previous = ->
    $scope.current_alternative? and $scope.current_alternative.index() > 0
  $scope.has_next     = ->
    $scope.current_alternative? and $scope.current_alternative.index() < Alternative.all.length-1 
  $scope.previous     = ->
    $scope.pick Alternative.all[$scope.current_alternative.index()-1]
  $scope.next         = ->
    $scope.pick Alternative.all[$scope.current_alternative.index()+1]

  $scope.row = (index) -> Math.floor index/3

]
