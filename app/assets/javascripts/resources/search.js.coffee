@rating.factory 'Search', ["$http", ($http) ->

  fetch: (query, callback) ->
    $http.get("/search/fetch.json?query=#{ query }").success callback

]