###*
# @ngdoc overview
# @name readme
# @description
# # Test
###
myApp = angular.module('myApp', ['kdNav'])

myApp.config(['kdNavProvider', (kdNavProvider) ->  
  # set up routes
  kdNavProvider.configRoutes
    home:
      route: '/'
      label: 'Home'
      templateUrl: 'home.html'
      controller: 'HomeCtrl'
    help:
      route: '/help'
      label: 'Help'
      templateUrl: 'help.html'
    '404':
      route: '/404'
      template: '404.html'
      default: true
    # public routes
    public:
      route: '/public'
      label: 'Public'
      templateUrl: 'public.html'
      controller: 'PublicCtrl'
    publicPageOne:
      route: '/public/pageone'
      label: 'Page One'
      extend: 'public'
    publicPageTwo:
      route: '/public/pagetwo'
      label: 'Page Two'
      extend: 'public'
    # admin routes
    admin:
      route: '/admin'
      label: 'Admin'
      forward: 'adminSettings'
      params: {param:'test123'} # pass params when replace current path
    adminSettings:
      route: '/admin/settings/:param'
      label: 'Settings'
      templateUrl: 'admin.html'
      controller: 'AdminCtrl'
    adminGroups:
      route: '/admin/groups'
      label: 'Organize Groups'
      extend: 'adminSettings' 
    adminUsers:
      route: '/admin/groups/:groupId/users'
      label: 'Organize Users'
      extend: 'adminSettings'
    adminUserEdit:
      route: '/admin/groups/:groupId/users/:userId'
      label: 'Edit User'
      extend: 'adminSettings'
  # set up static navigation tree
  .addMenu('mainMenu',[
    {routeName:'public'}
    {routeName:'admin'}
    {routeName:'help'}
  ]) # mainMenu
]) # config

myApp.controller('HomeCtrl', ['$scope', 'kdNav', ($scope, kdNav) ->
  console.log 'HomeCtrl'
  # generate link
  $scope.adminUserEditLink = kdNav.createPath('adminUserEdit', {groupId:1, userId:7})
  # change breadcrumbs-label
  kdNav.getBreadcrumb('home').label = 'Welcome'
])

myApp.controller('PublicCtrl', ['$scope', 'kdNav', ($scope, kdNav) -> 
  console.log 'PublicCtrl'
  # define menu
  items = [
    {routeName:'publicPageOne'}
    {routeName:'publicPageTwo'}
  ] # items
  kdNav.addMenu('publicMenu', items) # addMenu
])

myApp.controller('AdminCtrl', ['$scope', 'kdNav', ($scope, kdNav) -> 
  console.log 'AdminCtrl'
  # define menu
  items = [
    {routeName:'adminSettings'}
    {routeName:'adminGroups', children:[
      {routeName:'adminUsers', label:'Users', params:{groupId:1}}
      {routeName:'adminUsers', label:'Admins', params:{groupId:2}}
    ]}
  ] # items
  kdNav.addMenu('adminMenu', items, $scope) # addMenu
])