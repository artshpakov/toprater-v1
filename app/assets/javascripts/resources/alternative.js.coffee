@rating.factory 'Alternative', ["$resource", ($resource) ->
  criterion_ids_to_s = (criteria) -> _.pluck(criteria, 'id').join(',')

  _.tap $resource('/alternatives/:id.json', { id: '@id' }, { update: { method: 'PUT' } }), (Alternative) ->
    Alternative.rate = (criteria) ->
      @query(criterion_ids: criterion_ids_to_s(criteria)).$promise if criteria.length

    Alternative.pick = (id, criteria) ->
      @get(id: id, criterion_ids: criterion_ids_to_s(criteria)).$promise
]
