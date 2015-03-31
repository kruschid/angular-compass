
/**
 * @ngdoc overview
 * @name readme
 * @description
 * # Test
 */

(function() {
  var myApp;

  myApp = angular.module('myApp', ['kdNav']);

  myApp.config([
    'kdNavProvider', function(kdNavProvider) {
      return kdNavProvider.configRoutes({
        home: {
          route: '/',
          label: 'Home',
          templateUrl: 'home.html',
          controller: 'HomeCtrl'
        },
        help: {
          route: '/help',
          label: 'Help',
          templateUrl: 'help.html'
        },
        '404': {
          route: '/404',
          template: '404.html',
          "default": true
        },
        "public": {
          route: '/public',
          label: 'Public',
          templateUrl: 'public.html',
          controller: 'PublicCtrl'
        },
        publicPageOne: {
          route: '/public/pageone',
          label: 'Page One',
          extend: 'public'
        },
        publicPageTwo: {
          route: '/public/pagetwo',
          label: 'Page Two',
          extend: 'public'
        },
        admin: {
          route: '/admin',
          label: 'Admin',
          forward: 'adminSettings',
          params: {
            param: 'test123'
          }
        },
        adminSettings: {
          route: '/admin/settings/:param',
          label: 'Settings',
          templateUrl: 'admin.html',
          controller: 'AdminCtrl'
        },
        adminGroups: {
          route: '/admin/groups',
          label: 'Organize Groups',
          extend: 'adminSettings'
        },
        adminUsers: {
          route: '/admin/groups/:groupId/users',
          label: 'Organize Users',
          extend: 'adminSettings'
        },
        adminUserEdit: {
          route: '/admin/groups/:groupId/users/:userId',
          label: 'Edit User',
          extend: 'adminSettings'
        }
      }).addMenu('mainMenu', [
        {
          routeName: 'public'
        }, {
          routeName: 'admin'
        }, {
          routeName: 'help'
        }
      ]);
    }
  ]);

  myApp.controller('HomeCtrl', [
    '$scope', 'kdNav', function($scope, kdNav) {
      console.log('HomeCtrl');
      $scope.adminUserEditLink = kdNav.createPath('adminUserEdit', {
        groupId: 1,
        userId: 7
      });
      return kdNav.getBreadcrumb('home').label = 'Welcome';
    }
  ]);

  myApp.controller('PublicCtrl', [
    '$scope', 'kdNav', function($scope, kdNav) {
      var items;
      console.log('PublicCtrl');
      items = [
        {
          routeName: 'publicPageOne'
        }, {
          routeName: 'publicPageTwo'
        }
      ];
      return kdNav.addMenu('publicMenu', items);
    }
  ]);

  myApp.controller('AdminCtrl', [
    '$scope', 'kdNav', function($scope, kdNav) {
      var items;
      console.log('AdminCtrl');
      items = [
        {
          routeName: 'adminSettings'
        }, {
          routeName: 'adminGroups',
          children: [
            {
              routeName: 'adminUsers',
              label: 'Users',
              params: {
                groupId: 1
              }
            }, {
              routeName: 'adminUsers',
              label: 'Admins',
              params: {
                groupId: 2
              }
            }
          ]
        }
      ];
      return kdNav.addMenu('adminMenu', items, $scope);
    }
  ]);

}).call(this);
