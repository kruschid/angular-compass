
/**
 * @ngdoc overview
 * @name readme
 * @description
 * # Test
 */

(function() {
  var myApp;

  myApp = angular.module('myApp', ['ngCompass']);

  myApp.config([
    'ngCompassProvider', function(ngCompassProvider) {
      return ngCompassProvider.addRoutes({
        home: {
          route: '/',
          label: 'Home',
          templateUrl: 'home.html'
        },
        breadcrumbs: {
          route: '/breadcrumbs',
          label: 'Breadcrumbs',
          templateUrl: 'breadcrumbs.html',
          controller: 'BreadcrumbsCtrl'
        },
        links: {
          route: '/links',
          label: 'Links',
          templateUrl: 'links.html',
          controller: 'LinksCtrl'
        },
        menus: {
          route: '/menus',
          label: 'Menus',
          templateUrl: 'menus.html',
          controller: 'MenusCtrl'
        },
        subMenus: {
          route: '/menus/:menuId',
          label: 'Submenu',
          inherit: 'menus'
        },
        subSubMenus: {
          route: '/menus/:menuId/:subMenuId',
          label: 'Subsubmenu',
          inherit: 'menus'
        },
        error: {
          route: '/error/:code',
          templateUrl: 'error.html',
          controller: 'ErrorCtrl'
        },
        "default": {
          redirectTo: '/error/404',
          "default": true
        }
      }).addMenu('mainMenu', [
        {
          routeName: 'breadcrumbs'
        }, {
          routeName: 'links'
        }, {
          routeName: 'menus'
        }
      ]);
    }
  ]);

  myApp.controller('BreadcrumbsCtrl', function($scope, ngCompass) {
    ngCompass.getBreadcrumb('home').label = 'Welcome';
    return ngCompass.getBreadcrumb('home').params.search = 'Alan Turing';
  });

  myApp.controller('LinksCtrl', [
    '$scope', 'ngCompass', function($scope, ngCompass) {
      return $scope.path = ngCompass.createPath('subSubMenus', {
        menuId: 1,
        subMenuId: 7,
        searchABC: '#this/is?a=test&so=what'
      });
    }
  ]);

  myApp.controller('MenusCtrl', [
    '$scope', 'ngCompass', function($scope, ngCompass) {
      var items;
      items = [
        {
          routeName: 'subMenus',
          params: {
            menuId: 1
          },
          children: [
            {
              routeName: 'subSubMenus',
              params: {
                subMenuId: 1
              }
            }
          ]
        }, {
          routeName: 'subMenus',
          params: {
            menuId: 2
          },
          children: [
            {
              routeName: 'subSubMenus',
              params: {
                subMenuId: 2
              }
            }, {
              routeName: 'subSubMenus',
              label: 'Overwritten Label',
              params: {
                subMenuId: 3
              }
            }
          ]
        }
      ];
      return ngCompass.addMenu('extraMenu', items, $scope);
    }
  ]);

  myApp.controller('ErrorCtrl', function($scope, $routeParams, ngCompass) {
    ngCompass.getBreadcrumb('error').label = "Error " + $routeParams.code;
    return $scope.code = $routeParams.code;
  });

}).call(this);
