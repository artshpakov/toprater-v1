@rating.factory 'Search', ["$resource", ($resource) ->

  cache = []

  Search = $resource '/search.json', {},
    fetch: { url: '/search/fetch.json', isArray: true }

  Search.items = cache

  Search.active     = -> _.where cache, active: true
  Search.criteria   = -> _.where cache, active: true, type: 'criterion'
  Search.properties = -> _.where cache, active: true, type: 'property'

  Search.is_picked = (item) ->
    item in cache
  Search.pick = (item) ->
    unless @is_picked item
      item.active = true
      cache.push item
  Search.drop = (item) ->
    cache.splice cache.indexOf(item), 1


  Search.reset = -> @items = []

  Search

]
