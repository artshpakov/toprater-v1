@rating.factory 'Alternative', ["$resource", "Criterion", "Search", "$http", ($resource, Criterion, Search, $http) ->

  criteria_to_params = ->
    ids = _.pluck(Search.criteria(), 'id')
    criterion_ids: ids.join(',') if ids.length
  filters_to_params  = ->
    _.tap {}, (hash) -> for filter in Search.properties()
      hash["prop[#{ filter.id }]"] = 1


  Alternative = $resource '/:realm/alternatives/:id.json', { id: '@id', realm: 'hotels' }, update: { method: 'PUT' }
  # TODO get rid of hardcoded realm value

  Alternative.all = []

  Alternative::index = ->
    Alternative.all.indexOf @

  Alternative.rate = ->
    params = _.extend filters_to_params(), criteria_to_params()
    # unless _.isEmpty(params)
    @query(params).$promise.then (alternatives) =>
      @all = _.map(alternatives, (alternative) -> new Alternative alternative)

  Alternative.pick = (id) ->
    @get(_.extend { id }, criteria_to_params(Search.criteria)).$promise

  Alternative::lazy_fetch = ->
    unless @detailed
      params = ("#{ field }=#{ value }" for field, value of criteria_to_params(Search.criteria)).join("&")
      $http.get("/#{ @realm }/alternatives/#{ @id }/midlevel.json?#{ params }").success (data) =>
        for own attribute, value of data
          @[attribute] = value unless @[attribute]
        @detailed = true

  Alternative::top_criteria = ->
    _.map @top, (tip) ->
      _.find Criterion.all, (criterion) -> criterion.id is tip.id

  Alternative::grade = (criterion) ->
    _.find(@top, (tip) -> tip.id is criterion.id)?.grade

  Alternative::get_rating = (criterion) ->
    _.findWhere(@top, { id: criterion.id }).rating

  Alternative::progress = (criterion) -> (
    PARTION_AMOUNT = 10

    if @scores && @scores[criterion.id]
      position = @scores[criterion.id].position
      total    = @scores[criterion.id].out_of

      # normalize
      position  = total if position > total
      partition = total / PARTION_AMOUNT

      PARTION_AMOUNT - Math.floor(position / partition)

    else
      0
  )

  Alternative::url = (locale) ->
    "/#{ locale }/#{ @realm }/alternatives/#{ @id }"

  Alternative

]
