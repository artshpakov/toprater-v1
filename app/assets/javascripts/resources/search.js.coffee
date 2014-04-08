@rating.factory 'Search', ["$resource", ($resource) ->

  cache = []

  Search = $resource '/search.json', {},
    fetch: { url: '/search/fetch.json', isArray: true }

  Search.items = cache

  Search.criteria =   -> _.filter cache, (item) -> item.type is 'criterion'
  Search.properties = -> _.filter cache, (item) -> item.type is 'property'

  Search.is_picked = (item) ->
    item in cache
  Search.pick = (item) ->
    cache.push item unless @is_picked item
  Search.drop = (item) ->
    cache.splice cache.indexOf(item), 1


  Search.reset = -> @items = []

  Search

]
