@rating.config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->

  $routeProvider.when '/',
    templateUrl: '/assets/rating.html.slim'

  $routeProvider.when '/alternatives/:id',
    templateUrl: '/assets/details.html.slim'
    controller: 'rating.DetailsCtrl'

  $routeProvider.otherwise redirectTo: '/'

  $locationProvider.html5Mode(true)
]
