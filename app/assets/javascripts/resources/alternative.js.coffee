@rating.factory 'Alternative', ["$resource", "$http", "Criterion", "Property", ($resource, $http, Criterion, Property) ->
  criteria_to_s = (criteria) -> _.pluck(criteria, 'id').join(',')
  filters_to_s  = (filters) -> _.tap {}, (hash) ->
    for id, value of filters
      hash["properties[#{ id }]"] = 1 if value

  _.tap $resource('/alternatives/:id.json', { id: '@id' }, { update: { method: 'PUT' } }), (Alternative) ->

    all: []

    Alternative.rate = ->
      params = _.extend filters_to_s(Property.active), { criterion_ids: criteria_to_s(Criterion.active) }
      @query(params).$promise.then (alternatives) => @all = alternatives

    Alternative.count = (filters) ->
      params = ("#{k}=#{v}" for k,v of filters_to_s(Property.active)).join("&")
      $http.get("/alternatives/count.json?#{ params }")

    Alternative.pick = (id, criteria) ->
      @get(id: id, criterion_ids: criteria_to_s(criteria)).$promise

]
