@rating.factory 'Criterion', ["$resource", "data", ($resource, data) ->

  _.tap $resource('/criteria/:id', { id: '@id' }), (Criterion) ->

    criteria_cache = _.map data.criteria, (root) ->
      _.tap root, (root) ->
        root.children = _.map root.children, (child) ->
          new Criterion _.extend { state: null }, child

    picked_criteria_cache = []
    active_criteria_cache = []


    Criterion.all     = criteria_cache
    Criterion.picked  = picked_criteria_cache
    Criterion.active  = active_criteria_cache
    Criterion.leafs   = _.flatten _.map criteria_cache, (c) -> c.children

    Criterion::is_active    = -> @state is 'active'
    Criterion::is_inactive  = -> @state is 'inactive'

    Criterion::set_state    = (state) ->
      if state?
        picked_criteria_cache.push @ unless @ in picked_criteria_cache
        active_criteria_cache.push @ if state is 'active' and not (@ in active_criteria_cache)
      else
        picked_criteria_cache.splice picked_criteria_cache.indexOf(@), 1
      active_criteria_cache.splice(active_criteria_cache.indexOf(@), 1) if state isnt 'active'
      @state = state

    Criterion::toggle_state = (from, to=null) ->
      @state = if @state is to then @set_state(from) else @set_state(to)

    Criterion::pick = -> @set_state 'active'
    Criterion::drop = -> @set_state()

    Criterion.reset = ->
      _.each _.clone(@picked), (criterion) -> criterion.set_state(null)

]
