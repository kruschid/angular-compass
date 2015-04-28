
/**
 * @ngdoc module
 * @name ngCompass
 * @description
 * # ngCompass Module
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
  var NgCompass, ngCompassModule;

  ngCompassModule = angular.module('ngCompass', ['ngRoute']);


  /**
   * @ngdoc provider
   * @name ngCompassProvider
   * @requires $routeProvider
   * @returns {ngCompassProvider} Returns reference to ngCompassProvider
   * @description 
   * Provides setters for routes- and method configuration
   */

  ngCompassModule.provider('ngCompass', [
    '$routeProvider', function($routeProvider) {

      /**
       * @ngdoc property
       * @name ngCompassProvider#_routes
       * @description
       * Contains route config. Each route is mapped to route name.
       *
       * **Route-Format:**
       *
       *   <routeName>: # for referencing in menu, breadcrumbs and path-directive you must define a routeName
       *     route: <route-string> 
       *     label: <label-string> # label will be used by breadcrumbs and menu directive 
       *     default: <true|false> # if true this route will be used if no route matches the current request 
       *     inherit: <routeName of other route> # inherit properties except the default property from other route
       *     
       *     ... $routeProvider.when() options. e.g.:  
       *    
       *     templateUrl: <tempalteUrl>
       *     controller: <controllerName>
       *     redirectTo: <path>
       *
       *     ... more $routeProvider options ...   
       *
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
       *     inherit: 'home' # inherit properties from home-route
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
       * @name ngCompassProvider#_menus
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
       *       routeName: <routeName>  # routeName to reference a route in route configuration {@link ngCompassProvider#_routes}
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
       *   prepared: false # true after menu was pass to {@link ngCompass#_prepareMenu} 
       *   parsed: false # true after passing mainMenu to {@link ngCompass#_parseMenu} and again false on $routeChangeSuccess
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
       * @name ngCompassProvider#_menus._add
       * @param {string} menuName Name of menu
       * @param {Object} menuItems See {@link ngCompassProvider#_menus}
       * @returns {ngCompassProvider#_menus} 
       * @description
       * Setter for {@link ngCompassProvider#_menus}
       */
      this._menus._add = function(menuName, menuItems) {
        if (this[menuName]) {
          console.log("Warning: '" + menuName + "' already defined. (ngCompassProvider._menus._add)");
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
       * @name ngCompassProvider#configRoutes
       * @param {Object} _routes See {@link ngCompassProvider#_routes}
       * @returns {ngCompassProvider} Chainable Method returns reference to ngCompassProvider.
       * @description
       * Loops over each route definition to:
       * * implement inheritence of routes 
       * * but excludes the 'default' property from that inheritance
       * * configure routes by inserting them to $routeProvider
       * * configure 'default' route for the case that any routes don't match a request
       */
      this.addRoutes = function(_routes) {
        var inherit, routeName;
        for (routeName in _routes) {
          if (this._routes[routeName]) {
            console.log("Warning: '" + routeName + "' already defined. (ngCompassProvider.addRoutes)");
          } else {
            inherit = _routes[routeName].inherit;
            if (_routes[inherit] != null) {
              _routes[routeName] = angular.extend({}, _routes[inherit], _routes[routeName]);
              if (_routes[inherit]["default"]) {
                _routes[routeName]["default"] = false;
              }
            } else if (inherit != null) {
              console.log("Warning: " + routeName + " can't inherit from " + inherit + ". Not able to found " + inherit + ". (ngCompassProvider.addRoutes)");
            }
            $routeProvider.when(_routes[routeName].route, _routes[routeName]);
            if (_routes[routeName]["default"]) {
              $routeProvider.otherwise(_routes[routeName]);
            }
            this._routes[routeName] = _routes[routeName];
          }
        }
        return this;
      };

      /**
       * @ngdoc method
       * @name ngCompassProvider#addMenu
       * @param {string} menuName Name of menu
       * @param {Object} menuItems See {@link ngCompassProvider#_menus}
       * @returns {ngCompassProvider} Chainable Method returns reference to ngCompassProvider.
       * @description
       * Setter for {@link ngCompassProvider#_menus}
       */
      this.addMenu = function(menuName, menuItems) {
        this._menus._add(menuName, menuItems);
        return this;
      };

      /**
       * @ngdoc property
       * @name ngCompassProvider#$get
       * @description
       * Creates dependency-injection array to create NgCompass instance.
       * Passes therefore {@link ngCompassProvider#_routes} 
       * and {@link ngCompassProvider#_menus} to NgCompass.
       */
      this.$get = [
        '$rootScope', '$route', '$routeParams', '$location', function($rootScope, $route, $routeParams, $location) {
          return new NgCompass($rootScope, $route, $routeParams, $location, this._routes, this._menus);
        }
      ];
      return this;
    }
  ]);


  /**
   * @ngdoc type
   * @name NgCompass
   * @param {Object} $rootScope 
   * @param {Object} $route
   * @param {Object} $routeParams
   * @param {Object} _routes Contains the {@link ngCompassProvider#_routes 'routes object'}
   * @param {Object} _menus Contains the {@link ngCompassProvider#_menus 'menu object'}
   * @description
   * Type of {@link ngCompass 'ngCompass-service'}
   */


  /**
   * @ngdoc service
   * @name ngCompass
   * @requires $rootScope 
   * @requires $route
   * @requires $routeParams
   * @requires ngCompassProvider#_routes
   * @requires ngCompassProvider#_menus
   * @description
   * Regenerates breadcrumbs-array on route-change.
   * Provides interface methods to access and modify breadcrumbs elements.
   *  
   * Contains routes (route names mapped to routes), Breadcrumbs and Menu-Tree
   * Provides interface-methods for access to routes, breadcrumbs and menu
   * Provides methods for manipulation of breadcrumbs
   * Can be injected into other Angular Modules
   */

  NgCompass = function($rootScope, $route, $routeParams, $location, _routes, _menus) {

    /**
     * @ngdoc property
     * @name ngCompass#_breadcrumbs._path
     * @description
     * Contains breadcrumbs
     * 
     * **Format:**
     * ```
     * routeName: <routeName>  # routeName to reference a route in route configuration {@link ngCompassProvider#_routes} 
     * label: <label-string>   # copy of the default label from route configuration {@link ngCompassProvider#_routes} 
     * params: <param object>  # params automatically inserted from $routeParams but can be modified from any controller with {@link ngCompass#getBreadcrumb}
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
    this._breadcrumbs = {};
    this._breadcrumbs._path = [];

    /**
     * @ngdoc method
     * @name ngCompass#_breadcrumbs._add
     * @param {String} routeName Routename-string, e.g. '/citites/:cityId/shops/:shopId'
     * @returns {ngCompass} Chainable method
     * @description
     * Finds routeName for route-string passed as param.
     * Adds routeName and corresponding label to {@link ngCompass#_breadcrumbs 'breadcrumbs array'}
     */
    this._breadcrumbs._add = function(route) {
      var conf, rn, routeName;
      for (rn in _routes) {
        conf = _routes[rn];
        if (conf.route === route) {
          routeName = rn;
        }
      }
      if (routeName) {
        this._path.push({
          routeName: routeName,
          label: _routes[routeName].label,
          params: {}
        });
      }
      return this;
    };

    /**
     * @ngdoc method
     * @name ngCompass#getBreadcrumbs
     * @returns {Array} {@link ngCompass#_breadcrumbs 'breadcrumbs array'}
     */
    this.getBreadcrumbs = function() {
      return this._breadcrumbs._path;
    };

    /**
     * @ngdoc method
     * @name ngCompass#getBreadcrumb
     * @param {string} routeName A route-name to reference a route from {@link ngCompassProvider#_routes}
     * @returns {Object|undefined}
     */
    this.getBreadcrumb = function(routeName) {
      var breadcrumb, _i, _len, _ref;
      _ref = this.getBreadcrumbs();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        breadcrumb = _ref[_i];
        if (breadcrumb.routeName === routeName) {
          return breadcrumb;
        }
      }
      return console.log("Warning: no route entry for '" + routeName + "'. (ngCompass.getBreadcrumb)");
    };

    /**
     * @ngdoc method
     * @name ngCompass#_generateBreadcrumbs
     * @description
     * Thanks to Ian Walter: 
     * https://github.com/ianwalter/ng-breadcrumbs/blob/development/src/ng-breadcrumbs.js
     *
     * * Deletes all breadcrumbs.
     * * Splits current path-string to create a set of path-substrings.
     * * Compares each path-substring with configured routes.
     * * Matches then will be inserted into the current {@link ngCompass#_breadcrumbs 'breadcrumbs-path').
     */
    this._generateBreadcrumbs = function() {
      var element, routeElements, testRoute, testRouteElements, _i, _len, _results;
      this._breadcrumbs._path = [];
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
        _results.push(this._breadcrumbs._add(testRoute));
      }
      return _results;
    };

    /**
     * @ngdoc method
     * @name ngCompass#_prepareMenu
     * @param {Array} menuItems {@link ngCompassProvider#_menus}
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
     * @name ngCompass#_parseMenu
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
          _this._breadcrumbs._path.map(function(bc, k) {
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
            if (item.label != null) {
              _this._breadcrumbs._path[breadcrumbsIndex - 1].label = item.label;
            }
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
     * @name ngCompass#getMenu
     * @param {string} menuName Name of menu to return.
     * @returns {Object|undefined}
     */
    this.getMenu = function(menuName) {
      var menu;
      if (!_menus[menuName]) {
        console.log("Warning: '" + menuName + "' does not yet exist (ngCompass.getMenu)");
        return;
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
     * @name ngCompass#addMenu
     * @param {string} menuName Name of the menu
     * @param {Array} menuItems {@link ngCompassProvider#_menus}
     * @param {$scope} [$scope=false] Pass $scope if you want the menu to be deleted autmoatically on $destroy-event
     * @returns {ngCompass}
     * @descripton
     * Method to add dynamic menu from controllers
     * The $routeChangeSuccess event is fired before a menu can be passed throug this method,
     * so {@link ngCompass#_parseMenu} must be called directly after the menu gets prepared
     * by {@link ngCompass#_prepareMenu}.
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
     * @name ngCompass#createPath
     * @param {String} routeName Routename, e.g. 'citites'
     * @param {Object} [paramsOrig={}] Parameter object, e.g. {countryId:5,citityId:19,shopId:1}
     * @return {String|undefined} Anchor, e.g. e.g. '#countries/5/citites/19/shops/1' or undefined if routeName is invalid   
     * @description
     * Finds route by its routeName and returns its routePath with passed param values.
     * Performs fallback to $routeParams if the param-object passed as argument doesn't contain the required param(s)
     *
     * ** Example: **
     * ```
     * adminUserEdit.route = '/admin/groups/:groupId/users/:userId'
     *
     * ngCompass.createPath('adminUserEdit', {groupId: 1, userId:7, search:'hello'})
     * # returns '/admin/groups/1/users/7?search=hello'
     * ```
     */
    this.createPath = function(routeName, paramsOrig) {
      var params, replacer, route;
      if (paramsOrig == null) {
        paramsOrig = {};
      }
      params = angular.copy(paramsOrig);
      if (_routes[routeName]) {
        route = _routes[routeName].route;

        /**
         * @param {string} match full placeholder, e.g. :path*, :id, :search?
         * @param {string} paramName param name, e.g. path, id, search
         * @description
         * perfoms replacement of plaveholder in routestring
         * removes params were replaced
         */
        replacer = function(match, paramName) {
          var value, _ref;
          value = (_ref = params[paramName]) != null ? _ref : $routeParams[paramName];
          if (value != null) {
            if (params[paramName] != null) {
              delete params[paramName];
            }
            return encodeURIComponent(value);
          }
          console.log("Warning: " + paramName + " is undefined for route name: " + routeName + ". Route: " + route + ". (ngCompass.createPath)");
          return match;
        };
        route = route.replace(/(?::(\w+)(?:[\?\*])?)/g, replacer);
        if (!angular.equals(params, {})) {
          route += '?' + Object.keys(params).map(function(k) {
            return "" + k + "=" + (encodeURIComponent(params[k]));
          }).join('&');
        }
        return route;
      }
      return console.log("Warning: no route entry for '" + routeName + "'. (ngCompass.createPath)");
    };

    /**
     * Bind Listener
     * generates breadcrumbs
     * and sets all menus as not parsed
     */
    $rootScope.$on('$routeChangeSuccess', (function(_this) {
      return function() {
        var menuName, _results;
        if ($route.current.originalPath) {
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
   * @name ngCompassBreadcrumbs
   * @restrict AE
   * @description
   * Dislpays Breadcrumbs
   */

  ngCompassModule.directive('ngCompassBreadcrumbs', [
    'ngCompass', function(ngCompass) {
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
            return ngCompass.getBreadcrumbs();
          }, function() {
            return scope.breadcrumbs = ngCompass.getBreadcrumbs();
          });
        }
      };
      return directive;
    }
  ]);


  /**
   * @ngdoc directive
   * @name ngCompassMenu
   * @restrict AE
   * @property {string} ngCompassMenu name of menu to display
   * @description
   * Displays a menu
   */

  ngCompassModule.directive('ngCompassMenu', [
    'ngCompass', function(ngCompass) {
      var directive;
      directive = {
        restrict: 'AE',
        transclude: true,
        scope: {
          menuName: '@ngCompassMenu'
        },
        link: function(scope, el, attrs, ctrl, transcludeFn) {
          transcludeFn(scope, function(clonedTranscludedTemplate) {
            return el.append(clonedTranscludedTemplate);
          });
          return scope.$watch(function() {
            return ngCompass.getMenu(scope.menuName);
          }, function() {
            return scope.menu = ngCompass.getMenu(scope.menuName);
          });
        }
      };
      return directive;
    }
  ]);


  /**
   * @ngdoc directive
   * @name ngCompassPath
   * @restrict A
   * @element a
   * @property {string} ngCompassPath name of menu to display
   * @property {object=} ngCompassParams name of menu to display
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

  ngCompassModule.directive('ngCompassPath', [
    'ngCompass', function(ngCompass) {
      var directive;
      directive = {
        restrict: 'A',
        scope: {
          routeName: '@ngCompassPath',
          params: '=ngCompassParams'
        },
        link: function(scope, el, attr) {
          var updateHref;
          updateHref = function() {
            return attr.$set('href', "#" + (ngCompass.createPath(scope.routeName, scope.params)));
          };
          return scope.$watch('params', updateHref, true);
        }
      };
      return directive;
    }
  ]);

}).call(this);
