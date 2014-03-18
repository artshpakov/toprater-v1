@rating.factory 'Alternative', ["$resource", ($resource) ->
  $resource '/alternatives/:id.json', { id: '@id' }, { update: { method: 'PUT' } }
]


@rating.factory 'AlternativesCollection', ["$http", ($http) ->
  rate: (criteria) ->
    $http.get("/alternatives/rate?criterion_ids=#{ _.pluck(criteria, 'id').join(',') }") if criteria.length
]
