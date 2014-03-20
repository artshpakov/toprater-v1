@rating.factory 'Criterion', ["$resource", "data", ($resource, data) ->

  _.tap $resource('/criteria/:id', { id: '@id' }), (Criterion) ->

    criteria_cache = _.map data.criteria, (root) ->
      _.tap root, (root) ->
        root.children = _.map root.children, (child) ->
          new Criterion child

    active_criteria_cache = []


    Criterion.all     = criteria_cache
    Criterion.active  = active_criteria_cache

    Criterion::is_active      = -> @active
    Criterion::toggle_active  = ->
      if @active
        active_criteria_cache.splice active_criteria_cache.indexOf(@), 1
      else
        active_criteria_cache.push @
      @active = !@active

]
