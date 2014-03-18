@rating.factory 'AlternativesCollection', ["$http", ($http) ->
  rate: (criteria) ->
    $http.get("/alternatives/rate?criterion_ids=#{ _.pluck(criteria, 'id').join(',') }") if criteria.length
]
