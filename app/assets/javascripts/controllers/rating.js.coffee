@rating.controller "rating.RatingCtrl", ["$scope", "Alternative", ($scope, Alternative) ->

  $scope.current_alternative = Alternative.current_alternative
  $scope.$watch 'current_alternative', (alternative) ->
    scroll_to alternative if alternative?


  $scope.$watch 'criteria.active.length', ->
    Alternative.rate()
  $scope.$watch 'properties.picked.length', ->
    Alternative.rate()


  scroll_to = (alternative) -> _.defer ->
    element = angular.element("#middle#{ $scope.row alternative.index() }")[0]
    angular.element("body").animate { scrollTop: element.offsetTop - 70 }, 'fast'


  $scope.pick = (alternative) ->
    $scope.current_alternative = Alternative.current_alternative = alternative

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
