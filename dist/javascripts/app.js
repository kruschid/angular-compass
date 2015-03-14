(function() {
  var citiesController, contactController, countriesController, homeController, navConfig, shopDetailsController, shopsController;

  navConfig = function($routeProvider, kdNavProvider) {
    return kdNavProvider.configRoutes($routeProvider, {
      home: {
        route: '/',
        label: 'Home',
        templateUrl: 'home.html',
        controller: 'HomeCtrl',
        "default": true
      },
      countries: {
        route: '/countries',
        label: 'Countries',
        templateUrl: 'countries.html',
        controller: 'CountriesCtrl'
      },
      cities: {
        route: '/countries/:countryId/cities',
        label: 'Cities',
        templateUrl: 'countries.html',
        controller: 'CitiesCtrl'
      },
      shops: {
        route: '/countries/:countryId/cities/:cityId/shops',
        label: 'Shops',
        templateUrl: 'countries.html',
        controller: 'ShopsCtrl'
      },
      shopDetails: {
        route: '/countries/:countryId/cities/:cityId*/shops/:shopId?',
        label: 'Shop-Details',
        templateUrl: 'countries.html',
        controller: 'ShopDetailsCtrl'
      },
      contact: {
        route: '/contact',
        label: 'Contact',
        templateUrl: 'contact.html',
        controller: 'ContactCtrl'
      }
    }).configMenu({
      mainMenu: [
        {
          routeName: 'countries'
        }, {
          routeName: 'contact'
        }
      ],
      countriesMenu: [
        {
          routeName: 'cities',
          label: 'France',
          params: {
            countryId: 6
          }
        }, {
          routeName: 'cities',
          label: 'Denmark',
          params: {
            countryId: 10
          }
        }, {
          routeName: 'cities',
          label: 'Germany',
          params: {
            countryId: 1
          },
          children: [
            {
              routeName: 'shops',
              label: 'Trier',
              params: {
                cityId: 1
              }
            }, {
              routeName: 'shops',
              label: 'Berlin',
              params: {
                cityId: 2
              }
            }
          ]
        }
      ]
    });
  };

  homeController = function($scope, kdNav) {
    $scope.citiesLink = kdNav.getLink('cities', {
      countryId: 1,
      cityId: 7
    });
    return kdNav.getBreadcrumb('home').label = 'Welcome';
  };

  countriesController = function($scope) {};

  citiesController = function($scope) {};

  shopsController = function($scope) {};

  shopDetailsController = function($scope) {};

  contactController = function($scope) {};

  angular.module('kdNavApp', ['kdNav']).config(['$routeProvider', 'kdNavProvider', navConfig]).controller('HomeCtrl', ['$scope', 'kdNav', homeController]).controller('CountriesCtrl', countriesController).controller('CitiesCtrl', ['$scope', citiesController]).controller('ShopsCtrl', ['$scope', shopsController]).controller('ShopDetailsCtrl', ['$scope', shopDetailsController]).controller('ContactCtrl', ['$scope', contactController]);

}).call(this);
