@rating.filter "i18n", ->
  (phrase, params, determiner=null) ->
    I18n.translate phrase, params, determiner
