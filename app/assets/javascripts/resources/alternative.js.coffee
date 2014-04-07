@rating.factory 'Alternative', ["$resource", "$http", "Criterion", "Search", ($resource, $http, Criterion, Search) ->
  criteria_to_params = (criteria) ->
    _.pluck(criteria, 'id').join(',')
  filters_to_params  = (filters) ->
    _.tap {}, (hash) -> for filter in filters
      hash["prop[#{ filter.id }]"] = 1


  _.tap $resource('/alternatives/:id.json', { id: '@id' },
    update: { method: 'PUT' }
    count_filtered: { url: '/alternatives/count.json' }
  ), (Alternative) ->

    all: []

    Alternative::index = ->
      Alternative.all.indexOf @

    Alternative.rate = ->
      params = _.extend filters_to_params(Search.properties()), { criterion_ids: criteria_to_params(Search.criteria()) }
      @query(params).$promise.then (alternatives) =>
        @all = _.map(alternatives, (alternative) -> new Alternative alternative)

    Alternative.pick = (id, criteria) ->
      @get(id: id, criterion_ids: criteria_to_params(criteria)).$promise

    Alternative::top_criteria = ->
      _.map @top, (tip) ->
        _.find Criterion.leafs, (criterion) -> criterion.id is tip.id

    Alternative::grade = (criterion) ->
      _.find(@top, (tip) -> tip.id is criterion.id)?.grade

]
