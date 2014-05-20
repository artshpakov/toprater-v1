@rating.factory 'Search', ["$resource", "data", "Criterion", '$rootScope', ($resource, data, Criterion, $rootScope) ->

  cache = []

  Search = $resource '/search.json'

  Search.items = cache


  Search.active     = -> _.where cache, active: true
  Search.criteria   = -> _.where cache, active: true, type: 'criterion'
  Search.properties = -> _.where cache, active: true, type: 'property'
  Search.static_filters = -> _.where cache, active: true, type: 'static_filter'

  Search.is_picked = (item, value) ->
    if (value)
      item in cache and item.value == value
    else
      item in cache

  Search.pick = (item, activate=true, force_search=false) ->
    unless @is_picked(item)
      item.active = true if activate
      cache.push item

      # HACK: 
      # problem source: main.js.coffe $scope.StaticFilters.pick
      # we have one static filter with many values (hotel stars filter - 2,3,4,5)
      # So if i change value inside filter object - collection watcher doesn't triggered and no search request will be send
      # So i enforce this :D
      if force_search
        $rootScope.$broadcast('signal:force_search')

  Search.drop = (item) ->
    cache.splice cache.indexOf(item), 1


  Search.reset = -> cache = @items = []


  _.each data.preset, (pair) -> Search.pick Criterion.find(pair[0]), pair[1]

  Search

]
