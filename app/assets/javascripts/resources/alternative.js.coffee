@rating.factory 'Alternative', ["$resource", "Criterion", "Search", ($resource, Criterion, Search) ->

  criteria_to_params = ->
    _.pluck(Search.criteria(), 'id').join(',')
  filters_to_params  = ->
    _.tap {}, (hash) -> for filter in Search.properties()
      hash["prop[#{ filter.id }]"] = 1


  Alternative = $resource '/alternatives/:id.json', { id: '@id' }, update: { method: 'PUT' }

  Alternative.all = []

  Alternative::index = ->
    Alternative.all.indexOf @

  Alternative.rate = ->
    params = _.extend filters_to_params(), { criterion_ids: criteria_to_params() }
    @query(params).$promise.then (alternatives) =>
      @all = _.map(alternatives, (alternative) -> new Alternative alternative)

  Alternative.pick = (id, criteria) ->
    @get(id: id, criterion_ids: criteria_to_params(criteria)).$promise

  Alternative::top_criteria = ->
    _.map @top, (tip) ->
      _.find Criterion.all, (criterion) -> criterion.id is tip.id

  Alternative::grade = (criterion) ->
    _.find(@top, (tip) -> tip.id is criterion.id)?.grade

  Alternative

]
