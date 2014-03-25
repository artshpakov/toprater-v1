@rating.factory 'Property', ["$resource", "data", ($resource, data) ->

  items = data.properties

  all: items
  active: []

]
