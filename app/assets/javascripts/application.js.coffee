#= require jquery
#= require jquery_ujs

#= require angular
#= require angular-resource
#= require ng-rails-csrf

#= require_self
#= require_tree .


# $ -> $(document).foundation()

@rating = angular.module 'rating', ['ngResource', 'ng-rails-csrf']
@rating.value 'data', window.rating_data
