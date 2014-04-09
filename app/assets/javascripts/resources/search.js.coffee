@rating.factory 'Search', ["$http", ($http) ->

  fetch: (query, callback) ->
    $http.get("/search.json?q=#{ query }").success callback

]
