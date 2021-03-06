@rating.controller "rating.RatingCtrl", ["$scope", "$routeParams", "Alternative", "Search", '$rootScope', ($scope, $routeParams, Alternative, Search, $rootScope) ->

  $scope.$parent.realm = $routeParams.realm

  $scope.$watch 'search.items.length',    -> Alternative.rate()
  $scope.$watch 'search.active().length', -> Alternative.rate()
  $rootScope.$on 'signal:force_search', -> Alternative.rate()


  $scope.current_alternative = Alternative.current_alternative
  $scope.$watch 'current_alternative', (alternative) ->
    if alternative?
      alternative.lazy_fetch()
      scroll_to alternative

  $scope.pick = (alternative) ->
    $scope.current_alternative = Alternative.current_alternative = alternative


  $scope.unused = ->
    (criterion) => not Search.is_picked criterion


  scroll_to = (alternative) -> _.defer ->
    element = angular.element("#middle#{ $scope.row alternative.index() }")[0]
    angular.element("body").animate { scrollTop: element.offsetTop - 70 }, 'fast'

  $scope.belongs_here = (index) ->
    0 <= index - $scope.current_alternative.index() < $scope.cards_in_row
  $scope.last_in_row = (index) ->
    (index+1)%$scope.cards_in_row == 0 or index == Alternative.all.length-1

  $scope.has_previous = ->
    $scope.current_alternative? and $scope.current_alternative.index() > 0
  $scope.has_next     = ->
    $scope.current_alternative? and $scope.current_alternative.index() < Alternative.all.length-1 
  $scope.previous     = ->
    $scope.pick Alternative.all[$scope.current_alternative.index()-1] if $scope.has_previous()
  $scope.next         = ->
    $scope.pick Alternative.all[$scope.current_alternative.index()+1] if $scope.has_next()

  $scope.row = (index) -> Math.floor index/$scope.cards_in_row

  $scope.close_midlevel = ->
    $scope.current_alternative = undefined

  $scope.toggle_extended_version = (alternative) ->
    alternative.extended = !alternative.extended
    alternative.lazy_fetch()

]
