###*
# @ngdoc overview
# @name readme
# @description
# # Test
###
myApp = angular.module('myApp', ['ngCompass'])

myApp.config(['ngCompassProvider', (ngCompassProvider) ->  
  # set up routes
  ngCompassProvider.addRoutes
    home:
      route: '/'
      label: 'Home'
      templateUrl: 'home.html'
    breadcrumbs: 
      route: '/breadcrumbs'
      label: 'Breadcrumbs'
      templateUrl: 'breadcrumbs.html'
      controller: 'BreadcrumbsCtrl'
    links:
      route: '/links'
      label: 'Links'
      templateUrl: 'links.html'
      controller: 'LinksCtrl'
    menus:
      route: '/menus'
      label: 'Menus'
      templateUrl: 'menus.html'
      controller: 'MenusCtrl'
    subMenus:
      route: '/menus/:menuId'
      label: 'Submenu'
      inherit: 'menus'
    subSubMenus:
      route: '/menus/:menuId/:subMenuId'
      label: 'Subsubmenu'
      inherit: 'menus'
    error:
      route: '/error/:code'
      templateUrl: 'error.html'
      controller: 'ErrorCtrl'
    default:
      redirectTo: '/error/404'
      default: true
  # set up static navigation tree
  .addMenu('mainMenu',[
    {routeName:'breadcrumbs'}
    {routeName:'links'}
    {routeName:'menus'}
  ]) # mainMenu
]) # config

myApp.controller('BreadcrumbsCtrl', ($scope, ngCompass) ->
  # change breadcrumbs-label
  ngCompass.getBreadcrumb('home').label = 'Welcome'
  # change breadcrumbs-params
  ngCompass.getBreadcrumb('home').params.search = 'Alan Turing'
)

myApp.controller('LinksCtrl', ['$scope', 'ngCompass', ($scope, ngCompass) -> 
  # generate path
  $scope.path = ngCompass.createPath('subSubMenus', {menuId:1, subMenuId:7, searchABC:'#this/is?a=test&so=what'})
  # generate warning
])

myApp.controller('MenusCtrl', ['$scope', 'ngCompass', ($scope, ngCompass) -> 
  # define menu
  items = [
    {routeName:'subMenus', params:{menuId: 1}, children:[
      {routeName:'subSubMenus', params:{subMenuId: 1}}
    ]}
    {routeName:'subMenus', params:{menuId: 2}, children:[
      {routeName:'subSubMenus', params:{subMenuId:2}}
      {routeName:'subSubMenus', label:'Overwritten Label', params:{subMenuId:3}}
    ]}
  ] # items
  ngCompass.addMenu('extraMenu', items, $scope)
])

myApp.controller('ErrorCtrl', ($scope, $routeParams, ngCompass) ->
  # change breadcrumbs-label
  ngCompass.getBreadcrumb('error').label = "Error #{$routeParams.code}" 
  $scope.code = $routeParams.code
)