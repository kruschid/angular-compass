
/**
 * Contains routes (route names mapped to routes), Breadcrumbs and Menu-Tree
 * Provides interface-methods for access to routes, breadcrumbs and menu
 * Provides methods for manipulation of breadcrumbs
 * Can be injected into other Angular Modules
 *
 * @private
 * @class kdNav
 */

(function() {
  var kdNav, kdNavBreadcrumbsDirective, kdNavLinkTargetDirective, kdNavMenuDirective, kdNavProvider;

  kdNav = {

    /**
     * Contains route config. Each route is mapped to route name. Example:
     *
     *   _routes =
     *     home:
     *       route: '/'
     *       label: 'Home'
     *       templateUrl: 'home.html'
     *       controller: 'HomeCtrl'
     *       default: true
     *     cities:
     *       route: '/cities'
     *       label: 'Cities'
     *       templateUrl: 'cities.html'
     *       controller: 'CitiesCtrl'
     *     citiyDetails:
     *       route: '/cities/:cityId'
     *       label: 'Citiy-Details'
     *       templateUrl: 'city-details.html'
     *       controller: 'CityDetailsCtrl'
     *
     * Note that the home-route has the attribute 'default' with value 'true' wich means, 
     * that this route will be loaded if current route isn't valid
     *
     * @protected
     * @property _routes
     * @type Object
     */
    _routes: {},

    /**
     * breadcrumbs array contains breadcrumbs route Names in hierarchical order, last item is current site.
     * The path '/citites/5' corresponds to followind breadcrumbs-path
     *
     *   _breadcrumbs = [
     *     routeName: 'home'
     *     label: 'Home'
     *     params: {cityId:5}
     *     ,
     *     routeName: 'cities'
     *     label: 'Citites'
     *     params: {cityId:5}
     *     ,
     *     routeName: 'cityDetails'
     *     label: 'Citites'
     *     params: {cityId:5}
     *   ]
     *
     * @protected
     * @property _breadcrumbs
     * @type Array
     */
    _breadcrumbs: [],

    /**
     * Contains menu-tree
     *
     *   _menu = 
     *     @TODO
     *
     * @protected
     * @property _menu
     * @type Object
     */
    _menu: {},

    /**
     * @method setRoutes
     * @param {Object} routes See {{#crossLink "kdNav/_routes:attribute"}}{{/crossLink}} 
     * @chainable
     */
    setRoutes: function(_routes) {
      this._routes = _routes;
      return this;
    },

    /**
     * @method setMenu
     * @param {Object} menu See {{#crossLink "kdNav/_menu:attribute"}}{{/crossLink}} 
     * @chainable
     */
    setMenu: function(_menu) {
      this._menu = _menu;
      return this;
    },

    /**
     * Deletes all breadcrumbs
     *
     * @method _resetBreadcrumbs
     * @chainable
     */
    _resetBreadcrumbs: function() {
      this._breadcrumbs = [];
      return this;
    },

    /**
     * Adds one breadcrumb
     *
     * @method addBreadcrumb
     * @param {String} route Route-string, e.g. '/citites/:cityId/shops/:shopId'
     * @param {Object} params Route-params, e.g. {cityId:5, shopId:67}
     * @chainable
     */
    addBreadcrumb: function(route, params) {
      var routeName;
      routeName = this._getRouteName(route);
      if (routeName) {
        this._breadcrumbs.push({
          routeName: routeName,
          label: this._routes[routeName].label,
          params: params
        });
      }
      return this;
    },

    /**
     * @method getBreadcrumbs
     * @return {Array} {{#crossLink "kdNav/_breadcrumbs:attribute"}}breadcrumbs array{{/crossLink}}
     */
    getBreadcrumbs: function() {
      return this._breadcrumbs;
    },

    /**
     *
     * @return {Object|undefined}
     */
    getBreadcrumb: function(routeName) {
      var item;
      if ((function() {
        var _i, _len, _ref, _results;
        _ref = this.getBreadcrumbs();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          _results.push(item.routeName === routeName);
        }
        return _results;
      }).call(this)) {
        return item;
      }
      return console.log("no route entry for " + routeName);
    },

    /**
     *
     */
    getMenu: function(menuName) {
      return this._menu[menuName];
    },

    /**  
     * @protected
     * @method _getRouteName
     * @param {String} route Route, e.g. '/citites/5/shops/9'
     * @return {String|undefined} Route-name, e.g. 'shopDetails'
     */
    _getRouteName: function(route) {
      var conf, routeName, _ref;
      _ref = this._routes;
      for (routeName in _ref) {
        conf = _ref[routeName];
        if (conf.route === route) {
          return routeName;
        }
      }
    },

    /**
     * Creates breadcrumbs-generator-function and binds it to route-change-event
     * breadcrumbs-generator splits current route into components
     * and compares those components with all configured routes
     * mathes then will be inserted into the current breadcrumbs-path
     * @method bindBreadcrumbsGenerator
     * @param {Object} $rootScope
     * @param {Object} $route
     * @param {Object} $routeParams
     * @chainable
     */
    bindBreadcrumbsGenerator: function($rootScope, $route, $routeParams) {
      var generateBreadcrumbs;
      generateBreadcrumbs = (function(_this) {
        return function() {
          var element, routeElements, testRoute, testRouteElements, _i, _len, _results;
          if ($route.current.originalPath) {
            _this._resetBreadcrumbs();
            testRouteElements = [];
            routeElements = $route.current.originalPath.split('/');
            if (routeElements[1] === '') {
              routeElements.splice(1, 1);
            }
            _results = [];
            for (_i = 0, _len = routeElements.length; _i < _len; _i++) {
              element = routeElements[_i];
              testRouteElements.push(element);
              testRoute = testRouteElements.join('/') || '/';
              _results.push(_this.addBreadcrumb(testRoute, $routeParams));
            }
            return _results;
          }
        };
      })(this);
      $rootScope.$on('$routeChangeSuccess', generateBreadcrumbs);
      return this;
    },

    /**
     * @method bindMenuGenerator
     * @chainable
     */
    bindMenuGenerator: function($rootScope, $route, $routeParams) {

      /**
       * traverses menu-tree and finds current menu item 
       * dependency: prior generation of breadcrumb-list is required 
       *
       * sets recursively all nodes to non active and non current
       * converts node-params to string
       * make children inherit parents parameters
       * also finds active menu-items in the path to current menu item 
       * a) criteria for active menu-item
       *   1. menu-item is in current breadcrumb-list
       *   2. paramValues of current menu-item equal the current routeParams
       * b) criteria for current menu-item
       *   1. a) criteria for active meni-item
       *   2. menu-item is last element of breadcrumbs
       *
       * @private
       * @method traverseMenu
       * @param {Array} nodeList 
       * @param {Object} parentParams 
       * @return {Boolean}
       */
      var generateMenu, traverseMenu;
      traverseMenu = (function(_this) {
        return function(nodeList, parentParams) {
          var breadcrumbsIndex, node, param, paramName, paramsEquals, value, _i, _len, _ref, _results;
          if (parentParams == null) {
            parentParams = {};
          }
          _results = [];
          for (_i = 0, _len = nodeList.length; _i < _len; _i++) {
            node = nodeList[_i];
            node.active = node.current = false;
            if (node.label == null) {
              node.label = _this._routes[node.routeName].label;
            }
            for (paramName in node.params) {
              node.params[paramName] = node.params[paramName].toString();
            }
            node.params = angular.extend({}, parentParams, node.params);
            breadcrumbsIndex = void 0;
            _this.getBreadcrumbs().map(function(bc, k) {
              if (bc.routeName === node.routeName) {
                return breadcrumbsIndex = k + 1;
              }
            });
            paramsEquals = true;
            _ref = node.params;
            for (param in _ref) {
              value = _ref[param];
              if (value !== $routeParams[param]) {
                paramsEquals = false;
              }
            }
            if (breadcrumbsIndex && paramsEquals) {
              node.active = true;
              if (breadcrumbsIndex === _this.getBreadcrumbs().lenght) {
                node.current = true;
              }
            }
            if (node.children) {
              _results.push(traverseMenu(node.children, node.params));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        };
      })(this);
      generateMenu = (function(_this) {
        return function() {
          var menuName, _results;
          if ($route.current.originalPath) {
            _results = [];
            for (menuName in _this._menu) {
              _results.push(traverseMenu(_this._menu[menuName]));
            }
            return _results;
          }
        };
      })(this);
      $rootScope.$on('$routeChangeSuccess', generateMenu);
      return this;
    },

    /**
     * finds route by its routeName and returns its routePath with passed param values
     *
     * @method getLink
     * @param {String} routeName Routename, e.g. 'citites'
     * @param {Object} params Parameter object, e.g. {countryId:5,citityId:19,shopId:1}
     * @return {String|undefined} Anchor, e.g. e.g. '#countries/5/citites/19/shops/1' or undefined if routeName is invalid
     */
    getLink: function(routeName, params) {
      var key, route, value;
      if (this._routes[routeName]) {
        route = this._routes[routeName].route;
        for (key in params) {
          value = params[key];
          route = route.replace(":" + key, value);
        }
        return "#" + route;
      } else {
        return console.log("no route entry for " + routeName);
      }
    }
  };


  /**
   * Contains configuration methods for routes and menu
   * @private
   * @class kdNavProvider
   */

  kdNavProvider = {

    /**
     * Configures routes by inserting them to $routeProvider
     *
     * @method configRoutes
     * @param {Object} $routeProvider
     * @param {Object} routes See {{#crossLink "kdNav/_routes:attribute"}}{{/crossLink}} 
     * @chainable
     */
    configRoutes: function($routeProvider, routes) {
      var conf, routeName;
      kdNav.setRoutes(routes);
      for (routeName in routes) {
        conf = routes[routeName];
        $routeProvider.when(conf.route, {
          templateUrl: conf.templateUrl,
          controller: conf.controller
        });
        if (conf["default"]) {
          $routeProvider.otherwise({
            redirectTo: conf.route
          });
        }
      }
      return this;
    },

    /**
     * Configures menu
     *
     * @method configMenu
     * @param {Object} menu See {{#crossLink "kdNav/_menu:attribute"}}{{/crossLink}} 
     * @chainable
     */
    configMenu: function(menu) {
      kdNav.setMenu(menu);
      return this;
    },

    /**
     * $get method
     */
    $get: [
      '$rootScope', '$route', '$routeParams', function($rootScope, $route, $routeParams) {
        kdNav.bindBreadcrumbsGenerator($rootScope, $route, $routeParams);
        kdNav.bindMenuGenerator($rootScope, $route, $routeParams);
        return kdNav;
      }
    ]
  };


  /**
   * Breadcrumbs Directive
   */

  kdNavBreadcrumbsDirective = function(kdNav) {
    var directive;
    directive = {
      restrict: 'AE',
      transclude: true,
      scope: {},
      link: function(scope, el, attrs, ctrl, transcludeFn) {
        transcludeFn(scope, function(clonedTranscludedTemplate) {
          return el.append(clonedTranscludedTemplate);
        });
        return scope.$watch(function() {
          return kdNav.getBreadcrumbs();
        }, function() {
          return scope.breadcrumbs = kdNav.getBreadcrumbs();
        });
      }
    };
    return directive;
  };


  /**
   * MenuDirective
   */

  kdNavMenuDirective = function(kdNav) {
    var directive;
    directive = {
      restrict: 'AE',
      transclude: true,
      scope: {
        menuName: '@kdNavMenu'
      },
      link: function(scope, el, attrs, ctrl, transcludeFn) {
        transcludeFn(scope, function(clonedTranscludedTemplate) {
          return el.append(clonedTranscludedTemplate);
        });
        return scope.$watch(function() {
          return kdNav.getMenu(scope.menuName);
        }, function() {
          return scope.menu = kdNav.getMenu(scope.menuName);
        });
      }
    };
    return directive;
  };


  /**
   * Linkbuilder directive (funktioniert derzeit nur bei Anchor-Tags)
   * Verwendung:
   * <a mbc-link-builder="cameraEditor" mbc-link-params="{id:5}">Label</a>
   * erzeugt z.B.:
   * <a href="#/cameraEditor/5">Label</a>
   * falls zugehörige Route folgendermapen aussieht:
   * cameraEditor: '/cameraEditor/:id'
   */

  kdNavLinkTargetDirective = function(kdNav) {
    var directive;
    directive = {
      restrict: 'A',
      scope: {
        routeName: '@kdNavLinkTarget',
        params: '=kdNavLinkParams'
      },
      link: function(scope, el, attr) {
        var updateHref;
        updateHref = function() {
          return attr.$set('href', kdNav.getLink(scope.routeName, scope.params));
        };
        return scope.$watch('params', updateHref, true);
      }
    };
    return directive;
  };

  angular.module('kdNav', ['ngRoute']).provider('kdNav', kdNavProvider).directive('kdNavBreadcrumbs', ['kdNav', kdNavBreadcrumbsDirective]).directive('kdNavMenu', ['kdNav', kdNavMenuDirective]).directive('kdNavLinkTarget', ['kdNav', kdNavLinkTargetDirective]);

}).call(this);
