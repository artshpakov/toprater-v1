@rating.filter 'capitalize', ->
  (input, scope) ->
    if input?
      input = input.toLowerCase()
      input.substring(0,1).toUpperCase() + input.substring(1)
