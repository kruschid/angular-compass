
/**
 * @ngdoc module
 * @name kdNav
 * @description
 * # kdNav Module
 * ## Features
 * * Extended route features
 * * Breadcrumbs generation
 * * Breadcrumbs directive
 * * Static and dynamic menu generation
 * * Menu directive
 * * Path generation 
 * * Link directive
 */

(function() {
  var KdNav, kdNavModule;

  kdNavModule = angular.module('kdNav', ['ngRoute']);


  /**
   * @ngdoc provider
   * @name kdNavProvider
   * @requires $routeProvider
   * @returns {kdNavProvider} Returns reference to kdNavProvider
   * @description 
   * Provides setters for routes- and method configuration
   */

  kdNavModule.provider('kdNav', [
    '$routeProvider', function($routeProvider) {

      /**
       * @ngdoc property
       * @name kdNavProvider#_routes
       * @description
       * Contains route config. Each route is mapped to route name.
       *
       * **Route-Format:**
       * ```
       * <routeName>: # for referencing in menu, breadcrumbs and path-directive you must define a routeName
       *   route: <route-string> 
       *   templateUrl: <tempalteUrl>
       *   controller: <controllerName>
       *   label: <label-string> # label will be used by breadcrumbs and menu directive 
       *   default: <true|false> # if true this route will be used if no route matches the current request 
       *   extend: <routeName of other route> # inherit properties except the default property from other route
       *   forward: <routeName of other route> # automatically forward to other route
       *   params: <params object> # here you can pass params for the route referencing by forward property
       * ```
       *
       * **Example:**
       * ```
       * _routes =
       *   home:
       *     route: '/'
       *     label: 'Home'
       *     templateUrl: 'home.html'
       *     controller: 'HomeCtrl'
       *     default: true # if a request doesnt match any route forward to this route 
       *   info:
       *     route: '/info/:command'
       *     label: 'Info'
       *     extend: 'home' # inherit properties from home-route
       *   baseInfo:
       *     route: '/info'
       *     label: 'Info'
       *     forward: 'info' # goto info-route if this route is requested
       *     params: {command: 'all'} # use this params to forward to info-route
       * ```
       */
      this._routes = {};

      /**
       * @ngdoc property
       * @name kdNavProvider#_menus
       * @description
       * Contains menu-tree
       *
       * **Menu format:**
       * ```
       * _menus.<menuName> = 
       *   prepared: <true|false>      # if true then all params are converted to strings and children inherited parents params
       *   parsed: <true|false>        # true means that menu tree was parsed for active elements
       *   items: [
       *     {
       *       routeName: <routeName>  # routeName to reference a route in route configuration {@link kdNavProvider#_routes}
       *       label: <label-string>   # overwrite label defined in route-config (optional, doesn't affect labels displayed in breadcrumbs)
       *       params: <params-object> # parameter should be used for path generation (optional)
       *       children: [             # children and childrens children
       *         {routeName:<routeName>, label: ...}
       *         {routeName:<routeName>, children: [
       *           {routeName: ...}    # childrens children
       *         ]}
       *         ... # more children
       *       ]
       *     }
       *     ... # more menu items
       *   ]
       * ```
       *
       * **Example:**
       * ```
       * _menus.mainMenu =
       *   prepared: false # true after menu was pass to {@link kdNav#_prepareMenu} 
       *   parsed: false # true after passing mainMenu to {@link kdNav#_parseMenu} and again false on $routeChangeSuccess
       *   items: [
       *     {routeName:'admin', children:[
       *       {routeName:'groups', children:[
       *         {routeName:'group', label:'Admins', params:{groupId: 1}}
       *         {routeName:'group', label:'Editors', params:{groupId: 2}}
       *       ]} # groups-children
       *     ]} # admin-children
       *     {routeName:'contact'}
       *     {routeName:'help'}
       *   ] # mainMenu
       * ```
       */
      this._menus = {};

      /**
       * @ngdoc method
       * @name kdNavProvider#_menus._add
       * @param {string} menuName Name of menu
       * @param {Object} menuItems See {@link kdNavProvider#_menus}
       * @returns {kdNavProvider#_menus} 
       * @description
       * Setter for {@link kdNavProvider#_menus}
       */
      this._menus._add = function(menuName, menuItems) {
        if (this[menuName]) {
          console.log('warning:', menuName, 'is already defined');
        }
        this[menuName] = {
          prepared: false,
          parsed: false,
          items: menuItems
        };
        return this;
      };

      /**
       * @ngdoc method
       * @name kdNavProvider#configRoutes
       * @param {Object} _routes See {@link kdNavProvider#_routes}
       * @returns {kdNavProvider} Chainable Method returns reference to kdNavProvider.
       * @description
       * Loops over each route definition to:
       * * implement inheritence of routes 
       * * but excludes the 'default' property from that inheritance
       * * configure routes by inserting them to $routeProvider
       * * configure 'default' route for the case that any routes don't match a request
       */
      this.configRoutes = function(_routes) {
        var extend, routeName;
        this._routes = _routes;
        for (routeName in this._routes) {
          extend = this._routes[routeName].extend;
          if (extend) {
            this._routes[routeName] = angular.extend({}, this._routes[extend], this._routes[routeName]);
            if (this._routes[extend]["default"]) {
              this._routes[routeName]["default"] = false;
            }
          }
          $routeProvider.when(this._routes[routeName].route, this._routes[routeName]);
          if (this._routes[routeName]["default"]) {
            $routeProvider.otherwise({
              redirectTo: this._routes[routeName].route
            });
          }
        }
        return this;
      };

      /**
       * @ngdoc method
       * @name kdNavProvider#addMenu
       * @param {string} menuName Name of menu
       * @param {Object} menuItems See {@link kdNavProvider#_menus}
       * @returns {kdNavProvider} Chainable Method returns reference to kdNavProvider.
       * @description
       * Setter for {@link kdNavProvider#_menus}
       */
      this.addMenu = function(menuName, menuItems) {
        this._menus._add(menuName, menuItems);
        return this;
      };

      /**
       * @ngdoc property
       * @name kdNavProvider#$get
       * @description
       * Creates dependency-injection array to create KdNav instance.
       * Passes therefore {@link kdNavProvider#_routes} 
       * and {@link kdNavProvider#_menus} to KdNav.
       */
      this.$get = [
        '$rootScope', '$route', '$routeParams', '$location', function($rootScope, $route, $routeParams, $location) {
          return new KdNav($rootScope, $route, $routeParams, $location, this._routes, this._menus);
        }
      ];
      return this;
    }
  ]);


  /**
   * @ngdoc type
   * @name KdNav
   * @param {Object} $rootScope 
   * @param {Object} $route
   * @param {Object} $routeParams
   * @param {Object} _routes Contains the {@link kdNavProvider#_routes 'routes object'}
   * @param {Object} _menus Contains the {@link kdNavProvider#_menus 'menu object'}
   * @description
   * Type of {@link kdNav 'kdNav-service'}
   */


  /**
   * @ngdoc service
   * @name kdNav
   * @requires $rootScope 
   * @requires $route
   * @requires $routeParams
   * @requires kdNavProvider#_routes
   * @requires kdNavProvider#_menus
   * @description
   * Regenerates breadcrumbs-array on route-change.
   * Provides interface methods to access and modify breadcrumbs elements.
   *  
   * Contains routes (route names mapped to routes), Breadcrumbs and Menu-Tree
   * Provides interface-methods for access to routes, breadcrumbs and menu
   * Provides methods for manipulation of breadcrumbs
   * Can be injected into other Angular Modules
   */

  KdNav = function($rootScope, $route, $routeParams, $location, _routes, _menus) {

    /**
     * @ngdoc property
     * @name kdNav#_breadcrumbs
     * @description
     * Contains breadcrumbs
     * 
     * **Format:**
     * ```
     * routeName: <routeName>  # routeName to reference a route in route configuration {@link kdNavProvider#_routes} 
     * label: <label-string>   # copy of the default label from route configuration {@link kdNavProvider#_routes} 
     * params: <param object>  # params automatically inserted from $routeParams but can be modified from any controller with {@link kdNav#getBreadcrumb}
     * ```
     *
     * **Example:**
     * ```
     * _breadcrumbs = [
     *   {routeName:'home',    label:'Welcome',     params:{groupId:1}}
     *   {routeName:'groups',  label:'All Groups',  params:{groupId:1}}
     *   {routeName:'users',   label:'Admin Group', params:{groupId:1}}
     * ]
     * 
     * # corresponds to '/groups/1/users'
     *```
     */
    this._breadcrumbs = [];

    /**
     * @ngdoc method
     * @name kdNav#getBreadcrumbs
     * @returns {Array} {@link kdNav#_breadcrumbs 'breadcrumbs array'}
     */
    this.getBreadcrumbs = function() {
      return this._breadcrumbs;
    };

    /**
     * @ngdoc method
     * @name kdNav#getBreadcrumb
     * @param {string} routeName A route-name to reference a route from {@link kdNavProvider#_routes}
     * @returns {Object|undefined}
     */
    this.getBreadcrumb = function(routeName) {
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
      return console.log('no route entry for', routeName);
    };

    /**
     * @ngdoc method
     * @name kdNav#_addBreadcrumb
     * @param {String} route Route-string, e.g. '/citites/:cityId/shops/:shopId'
     * @param {Object} params Route-params, e.g. {cityId:5, shopId:67}
     * @returns {kdNav} Chainable method
     * @description
     * Adds one breadcrumb
     */
    this._addBreadcrumb = function(route, params) {
      var conf, rn, routeName;
      for (rn in _routes) {
        conf = _routes[rn];
        if (conf.route === route) {
          routeName = rn;
        }
      }
      if (routeName) {
        this._breadcrumbs.push({
          routeName: routeName,
          label: _routes[routeName].label,
          params: params
        });
      }
      return this;
    };

    /**
     * @ngdoc method
     * @name kdNav#_generateBreadcrumbs
     * @description
     * Thanks to Ian Walter: 
     * https://github.com/ianwalter/ng-breadcrumbs/blob/development/src/ng-breadcrumbs.js
     *
     * * Deletes all breadcrumbs.
     * * Splits current path-string to create a set of path-substrings.
     * * Compares each path-substring with configured routes.
     * * Matches then will be inserted into the current {@link kdNav#_breadcrumbs 'breadcrumbs-path').
     */
    this._generateBreadcrumbs = function() {
      var element, routeElements, testRoute, testRouteElements, _i, _len, _results;
      this._breadcrumbs = [];
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
        _results.push(this._addBreadcrumb(testRoute, $routeParams));
      }
      return _results;
    };

    /**
     * @ngdoc method
     * @name kdNav#_prepareMenu
     * @param {Array} menuItems {@link kdNavProvider#_menus}
     * @param {Object} parentParams
     * @description
     * * Converts all params to string.
     * * Makes children items inherit parents parameters.
     */
    this._prepareMenu = function(menuItems, parentParams) {
      var item, paramName, _i, _len, _results;
      if (parentParams == null) {
        parentParams = {};
      }
      _results = [];
      for (_i = 0, _len = menuItems.length; _i < _len; _i++) {
        item = menuItems[_i];
        if (item.label == null) {
          item.label = _routes[item.routeName].label;
        }
        for (paramName in item.params) {
          item.params[paramName] = item.params[paramName].toString();
        }
        item.params = angular.extend({}, parentParams, item.params);
        if (item.children) {
          _results.push(this._prepareMenu(item.children, item.params));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    /**
     * @ngdoc method
     * @name kdNav#_parseMenu
     * @param {Array} menuItems The menu items (see {@link kNavProvider#_menus}) 
     * @description
     * Traverses menu-tree and finds current menu item 
     * dependency: prior generation of breadcrumb-list is required 
     *
     * Sets recursively all nodes to non active and non current
     * finds active menu-items in the path to current menu item 
     * a) criteria for active menu-item
     *   1. menu-item is in current breadcrumb-list
     *   2. paramValues of current menu-item equal the current routeParams
     * b) criteria for current menu-item
     *   1. a) criteria for active menu-item
     *   2. menu-item is last element of breadcrumbs
     */
    this._parseMenu = (function(_this) {
      return function(menuItems) {
        var breadcrumbsIndex, item, param, paramsEquals, value, _i, _len, _ref, _results;
        _results = [];
        for (_i = 0, _len = menuItems.length; _i < _len; _i++) {
          item = menuItems[_i];
          item.active = item.current = false;
          breadcrumbsIndex = void 0;
          _this._breadcrumbs.map(function(bc, k) {
            if (bc.routeName === item.routeName) {
              return breadcrumbsIndex = k + 1;
            }
          });
          paramsEquals = true;
          _ref = item.params;
          for (param in _ref) {
            value = _ref[param];
            if (value !== $routeParams[param]) {
              paramsEquals = false;
            }
          }
          if (breadcrumbsIndex && paramsEquals) {
            item.active = true;
            if (breadcrumbsIndex === _this.getBreadcrumbs().length) {
              item.current = true;
            }
          }
          if (item.children) {
            _results.push(_this._parseMenu(item.children, item.params));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
    })(this);

    /**
     * @ngdoc method
     * @name kdNav#getMenu
     * @param {string} menuName Name of menu to return.
     * @returns {Object|undefined}
     */
    this.getMenu = function(menuName) {
      var menu;
      if (!_menus[menuName]) {
        console.log(menuName, 'does not yet exist');
      }
      menu = _menus[menuName];
      if (!menu.prepared) {
        this._prepareMenu(menu.items);
        menu.prepared = true;
      }
      if (!menu.parsed) {
        this._parseMenu(menu.items);
        menu.parsed = true;
      }
      return menu.items;
    };

    /**
     * @ngdoc method
     * @name kdNav#addMenu
     * @param {string} menuName Name of the menu
     * @param {Array} menuItems {@link kdNavProvider#_menus}
     * @param {$scope} [$scope=false] Pass $scope if you want the menu to be deleted autmoatically on $destroy-event
     * @returns {kdNav}
     * @descripton
     * Method to add dynamic menu from controllers
     * The $routeChangeSuccess event is fired before a menu can be passed throug this method,
     * so {@link kdNav#_parseMenu} must be called directly after the menu gets prepared
     * by {@link kdNav#_prepareMenu}.
     * Creates a new child of $scope to delete the menu when controller get destroyed.
     * It could get expensive because generate menu
     */
    this.addMenu = function(menuName, menuItems, $scope) {
      var menuScope;
      if ($scope == null) {
        $scope = false;
      }
      _menus._add(menuName, menuItems);
      if ($scope) {
        menuScope = $scope.$new();
        menuScope.menuName = menuName;
        menuScope.$on('$destroy', (function(_this) {
          return function(e) {
            return delete _menus[e.currentScope.menuName];
          };
        })(this));
      }
      return this;
    };

    /**
     * @ngdoc method
     * @name kdNav#createPath
     * @param {String} routeName Routename, e.g. 'citites'
     * @param {Object} params Parameter object, e.g. {countryId:5,citityId:19,shopId:1}
     * @return {String|undefined} Anchor, e.g. e.g. '#countries/5/citites/19/shops/1' or undefined if routeName is invalid   
     * @description
     * Finds route by its routeName and returns its routePath with passed param values.
     * Example:
     * ```
     * adminUserEdit.route = '/admin/groups/:groupId/users/:userId'
     *
     * kdNav.createPath('adminUserEdit', {groupId: 1, userId:7})
     * # returns '/admin/groups/1/users/7'
     * ```
     */
    this.createPath = function(routeName, params) {
      var key, route, value;
      if (_routes[routeName]) {
        route = _routes[routeName].route;
        for (key in params) {
          value = params[key];
          route = route.replace(":" + key, value);
        }
        return "" + route;
      }
      return console.log('no route entry for', routeName);
    };

    /**
     * Bind Listener
     * Creates breadcrumbs-generator-function and binds it to route-change-event
     */
    $rootScope.$on('$routeChangeSuccess', (function(_this) {
      return function() {
        var conf, menuName, params, routeName, _results;
        if ($route.current.originalPath) {
          for (routeName in _routes) {
            conf = _routes[routeName];
            if (conf.route === $route.current.originalPath && conf.forward) {
              params = angular.extend({}, $routeParams, conf.params);
              $location.path(_this.createPath(conf.forward, params));
            }
          }
          _this._generateBreadcrumbs();
          _results = [];
          for (menuName in _menus) {
            _results.push(_menus[menuName].parsed = false);
          }
          return _results;
        }
      };
    })(this));
    return this;
  };


  /**
   * @ngdoc directive
   * @name kdNavBreadcrumbs
   * @restrict AE
   * @description
   * Dislpays Breadcrumbs
   */

  kdNavModule.directive('kdNavBreadcrumbs', [
    'kdNav', function(kdNav) {
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
    }
  ]);


  /**
   * @ngdoc directive
   * @name kdNavMenu
   * @restrict AE
   * @property {string} kdNavMenu name of menu to display
   * @description
   * Displays a menu
   */

  kdNavModule.directive('kdNavMenu', [
    'kdNav', function(kdNav) {
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
    }
  ]);


  /**
   * @ngdoc directive
   * @name kdNavPath
   * @restrict A
   * @element a
   * @property {string} kdNavPath name of menu to display
   * @property {object=} kdNavParams name of menu to display
   * @description
   * Linkbuilder directive generates path and puts it as value in href attribute on anchor tag.
   * Path geneartion depends on routeName and params.
   *
   * **Jade-Example:**
   * ```
   * a(kd-nav-path='adminUserEdit', kd-nav-params='{groupId: 1, userId:7}') Label
   * ```
   * Result: <a href="#/admin/groups/1/users/7">Label</a>
   */

  kdNavModule.directive('kdNavPath', [
    'kdNav', function(kdNav) {
      var directive;
      directive = {
        restrict: 'A',
        scope: {
          routeName: '@kdNavPath',
          params: '=kdNavParams'
        },
        link: function(scope, el, attr) {
          var updateHref;
          updateHref = function() {
            return attr.$set('href', "#" + (kdNav.createPath(scope.routeName, scope.params)));
          };
          return scope.$watch('params', updateHref, true);
        }
      };
      return directive;
    }
  ]);

}).call(this);
