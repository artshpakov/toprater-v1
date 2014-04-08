@rating.factory 'Criterion', ["$resource", "data", ($resource, data) ->

  Criterion = $resource '/criteria/:id', id: '@id'

  Criterion::type = 'criterion'

  cache = do ->
    items = []
    _.each data.criteria, (root) ->
      items = items.concat root.children.map (item) -> new Criterion item
    items

  Criterion.all = cache

  Criterion::toggle = -> @active = !@active

  Criterion

]
