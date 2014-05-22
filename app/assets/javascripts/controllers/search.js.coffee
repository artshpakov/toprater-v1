@rating.controller "rating.SearchCtrl", ["$scope", "$location", "$routeParams", "Criterion", "Property", "Search", ($scope, $location, $routeParams, Criterion, Property, Search) ->

  $scope.pick_tip = (tip) ->
    $routeParams.realm or $location.path "/#{ $scope.locale }/#{ tip.realm }"
    switch tip.type
      when 'criterion'
        Search.pick _.find(Criterion.all, (criterion) -> criterion.id is tip.id)
      when 'property'
        Search.pick _.find(Property.all, (property) -> property.id is tip.id)
      when 'realm'
        $location.path "/#{ $scope.locale }/#{ tip.realm }"
      when 'alternative'
        $location.path "/#{ $scope.locale }/#{ tip.realm }/alternatives/#{ tip.id }"

  $scope.search_box = {
    selected_object : null
    cleanSelected   : ->
      angular.element('#search-box').val('') # ugly shit

    options: { minLength: 2 }

    data: {
      displayKey: 'name'
      templates:
        suggestion: (tip) -> "<div class='result #{ tip.type }'>#{ tip.name }<small><span>#{ I18n.translate("main.#{tip.type}") }</span><span>#{ I18n.translate("realm.#{tip.realm}") }</span></small></div>"
      source: (search_term, callback_fn) ->
        Search.query {q: search_term}, (response) ->
          callback_fn(response)
    }
  } # $scope.search_box

  $scope.$on 'typeahead:selected', () ->
    $scope.$apply ->
      $scope.pick_tip($scope.search_box.selected_object)
      $scope.search_box.cleanSelected()

]
