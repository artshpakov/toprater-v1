@rating.factory 'Alternative', ["$resource", ($resource) ->
  criteria_to_s = (criteria) -> _.pluck(criteria, 'id').join(',')
  filters_to_s  = (filters) -> _.tap {}, (hash) ->
    hash["properties[#{ id }]"] = 1 for id, value of filters

  _.tap $resource('/alternatives/:id.json', { id: '@id' }, { update: { method: 'PUT' } }), (Alternative) ->
    Alternative.rate = (params) ->
      query_params = _.extend filters_to_s(params.filters), { criterion_ids: criteria_to_s(params.criteria) }
      @query(query_params).$promise

    Alternative.pick = (id, criteria) ->
      @get(id: id, criterion_ids: criteria_to_s(criteria)).$promise
]
