@rating.factory 'Search', ["$resource", "data", "Criterion", ($resource, data, Criterion) ->

  cache = []

  Search = $resource '/search.json'

  Search.items = cache


  Search.active     = -> _.where cache, active: true
  Search.criteria   = -> _.where cache, active: true, type: 'criterion'
  Search.properties = -> _.where cache, active: true, type: 'property'

  Search.is_picked = (item) ->
    item in cache
  Search.pick = (item, activate=true) ->
    unless @is_picked item
      item.active = true if activate
      cache.push item
  Search.drop = (item) ->
    cache.splice cache.indexOf(item), 1


  Search.reset = -> cache = @items = []


  _.each data.preset, (pair) -> Search.pick Criterion.find(pair[0]), pair[1]

  Search

]
