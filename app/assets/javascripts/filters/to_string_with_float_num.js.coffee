@rating.filter 'toStringWithFloatNum', ->
  (num = 0, presicion = 1) -> num.toFixed(presicion)
