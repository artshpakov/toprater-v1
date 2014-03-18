#= require jquery
#= require jquery_ujs
#= require underscore

#= require angular
#= require angular-resource
#= require angular-sanitize
#= require angular-route
#= require ng-rails-csrf

#= require_self
#= require_tree .


# $ -> $(document).foundation()

@rating = angular.module 'rating', ['ngResource', 'ngRoute', 'ng-rails-csrf', 'ngSanitize']
@rating.value 'data', window.rating_data
