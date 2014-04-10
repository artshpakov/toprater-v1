@rating.controller "rating.RatingCtrl", ["$scope", "Alternative", "Search", ($scope, Alternative, Search) ->

  $scope.$watch 'search.items.length',    -> Alternative.rate()
  $scope.$watch 'search.active().length', -> Alternative.rate()


  $scope.current_alternative = Alternative.current_alternative
  $scope.$watch 'current_alternative', (alternative) ->
    scroll_to alternative if alternative?

  $scope.pick = (alternative) ->
    $scope.current_alternative = Alternative.current_alternative = alternative


  $scope.unused = ->
    (criterion) => not Search.is_picked criterion


  scroll_to = (alternative) -> _.defer ->
    element = angular.element("#middle#{ $scope.row alternative.index() }")[0]
    angular.element("body").animate { scrollTop: element.offsetTop - 70 }, 'fast'

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
