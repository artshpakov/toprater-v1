@rating.filter 'withoutType', ->
  (collection, skip_type) ->
    _.select collection, (record) -> record.type != skip_type
