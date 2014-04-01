#= require jquery
#= require jquery_ujs
#= require foundation
#= require underscore
#= require i18n

#= require angular
#= require angular-resource
#= require angular-sanitize
#= require angular-route
#= require ng-rails-csrf

#= require_self
#= require_tree .
#= require vendor/modernizr


$ -> $(document).foundation()

@rating = angular.module 'rating', ['ngResource', 'ngRoute', 'ng-rails-csrf', 'ngSanitize']
@rating.value 'data', window.rating_data
@rating.value 'locale', window.i18njs.locale
