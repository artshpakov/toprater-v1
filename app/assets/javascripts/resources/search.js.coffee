@rating.factory 'Search', ["$http", ($http) ->

  cache = []

  items: cache

  fetch: (query, callback) ->
    $http.get("/search/fetch.json?query=#{ query }").success callback

  criteria:   -> _.filter cache, (item) -> item.type is 'criterion'
  properties: -> _.filter cache, (item) -> item.type is 'property'

  reset: -> @items = []

]
