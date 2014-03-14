@rating.factory 'AlternativesCollection', ["$http", ($http) ->
  rate: (criteria) ->
    if criteria.length
      $http.get("/alternatives/rate?criterion_ids=#{ _.pluck(criteria, 'id').join(',') }").then (ids) ->
        console.log ids
]
