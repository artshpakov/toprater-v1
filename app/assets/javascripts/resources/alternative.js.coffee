@rating.factory 'Alternative', ["$resource", "$http", "Criterion", "Property", ($resource, $http, Criterion, Property) ->
  criteria_to_params = (criteria) ->
    _.pluck(criteria, 'id').join(',')
  filters_to_params  = (filters) ->
    _.tap {}, (hash) -> for id, value of filters
      hash["prop[#{ id }]"] = 1 if value


  _.tap $resource('/alternatives/:id.json', { id: '@id' },
    update: { method: 'PUT' }
    count_filtered: { url: '/alternatives/count.json' }
  ), (Alternative) ->

    all: []

    Alternative.rate = ->
      params = _.extend filters_to_params(Property.active), { criterion_ids: criteria_to_params(Criterion.active) }
      @query(params).$promise.then (alternatives) =>
        @all = _.map(alternatives, (alternative) -> new Alternative alternative)

    Alternative.count = ->
      @count_filtered(filters_to_params(Property.active)).$promise

    Alternative.pick = (id, criteria) ->
      @get(id: id, criterion_ids: criteria_to_params(criteria)).$promise

]
