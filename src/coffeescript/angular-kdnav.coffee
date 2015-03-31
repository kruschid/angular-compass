# Relevanter Artikel über Provider:
# https://docs.angularjs.org/guide/providers
# Verwandtes Plugin:
# https://github.com/ianwalter/ng-breadcrumbs
# Verwandetes Plugin:
# https://github.com/mnitschke/angular-cc-navigation

###*
# @ngdoc module
# @name kdNav
# @description
# # kdNav Module
# ## Features
# * Extended route features
# * Breadcrumbs generation
# * Breadcrumbs directive
# * Static and dynamic menu generation
# * Menu directive
# * Path generation 
# * Link directive
###
kdNavModule = angular.module('kdNav', ['ngRoute'])

###*
# @ngdoc provider
# @name kdNavProvider
# @requires $routeProvider
# @returns {kdNavProvider} Returns reference to kdNavProvider
# @description 
# Provides setters for routes- and method configuration
###
kdNavModule.provider('kdNav', ['$routeProvider', ($routeProvider) ->
  ###*
  # @ngdoc property
  # @name kdNavProvider#_routes
  # @description
  # Contains route config. Each route is mapped to route name.
  #
  # **Route-Format:**
  # ```
  # <routeName>: # for referencing in menu, breadcrumbs and path-directive you must define a routeName
  #   route: <route-string> 
  #   templateUrl: <tempalteUrl>
  #   controller: <controllerName>
  #   label: <label-string> # label will be used by breadcrumbs and menu directive 
  #   default: <true|false> # if true this route will be used if no route matches the current request 
  #   extend: <routeName of other route> # inherit properties except the default property from other route
  #   forward: <routeName of other route> # automatically forward to other route
  #   params: <params object> # here you can pass params for the route referencing by forward property
  # ```
  #
  # **Example:**
  # ```
  # _routes =
  #   home:
  #     route: '/'
  #     label: 'Home'
  #     templateUrl: 'home.html'
  #     controller: 'HomeCtrl'
  #     default: true # if a request doesnt match any route forward to this route 
  #   info:
  #     route: '/info/:command'
  #     label: 'Info'
  #     extend: 'home' # inherit properties from home-route
  #   baseInfo:
  #     route: '/info'
  #     label: 'Info'
  #     forward: 'info' # goto info-route if this route is requested
  #     params: {command: 'all'} # use this params to forward to info-route
  # ```
  ###
  @_routes = {}

  ###*
  # @ngdoc property
  # @name kdNavProvider#_menus
  # @description
  # Contains menu-tree
  #
  # **Menu format:**
  # ```
  # _menus.<menuName> = 
  #   prepared: <true|false>      # if true then all params are converted to strings and children inherited parents params
  #   parsed: <true|false>        # true means that menu tree was parsed for active elements
  #   items: [
  #     {
  #       routeName: <routeName>  # routeName to reference a route in route configuration {@link kdNavProvider#_routes}
  #       label: <label-string>   # overwrite label defined in route-config (optional, doesn't affect labels displayed in breadcrumbs)
  #       params: <params-object> # parameter should be used for path generation (optional)
  #       children: [             # children and childrens children
  #         {routeName:<routeName>, label: ...}
  #         {routeName:<routeName>, children: [
  #           {routeName: ...}    # childrens children
  #         ]}
  #         ... # more children
  #       ]
  #     }
  #     ... # more menu items
  #   ]
  # ```
  #
  # **Example:**
  # ```
  # _menus.mainMenu =
  #   prepared: false # true after menu was pass to {@link kdNav#_prepareMenu} 
  #   parsed: false # true after passing mainMenu to {@link kdNav#_parseMenu} and again false on $routeChangeSuccess
  #   items: [
  #     {routeName:'admin', children:[
  #       {routeName:'groups', children:[
  #         {routeName:'group', label:'Admins', params:{groupId: 1}}
  #         {routeName:'group', label:'Editors', params:{groupId: 2}}
  #       ]} # groups-children
  #     ]} # admin-children
  #     {routeName:'contact'}
  #     {routeName:'help'}
  #   ] # mainMenu
  # ```
  ###
  @_menus = {}

  ###*
  # @ngdoc method
  # @name kdNavProvider#_menus._add
  # @param {string} menuName Name of menu
  # @param {Object} menuItems See {@link kdNavProvider#_menus}
  # @returns {kdNavProvider#_menus} 
  # @description
  # Setter for {@link kdNavProvider#_menus}
  ###
  @_menus._add = (menuName, menuItems) ->
    console.log 'warning:', menuName, 'is already defined' if @[menuName]
    @[menuName] =
      prepared: false
      parsed: false
      items: menuItems
    return @

  ###*
  # @ngdoc method
  # @name kdNavProvider#configRoutes
  # @param {Object} _routes See {@link kdNavProvider#_routes}
  # @returns {kdNavProvider} Chainable Method returns reference to kdNavProvider.
  # @description
  # Loops over each route definition to:
  # * implement inheritence of routes 
  # * but excludes the 'default' property from that inheritance
  # * configure routes by inserting them to $routeProvider
  # * configure 'default' route for the case that any routes don't match a request  
  ###
  @configRoutes = (@_routes) ->
    # register routes
    for routeName of @_routes
      extend = @_routes[routeName].extend
      # perform inheritance if route is extend
      if extend
        @_routes[routeName] = angular.extend({}, @_routes[extend], @_routes[routeName])
        # exculde 'default'-property from inheritance
        @_routes[routeName].default = false if @_routes[extend].default
      # register route
      $routeProvider.when @_routes[routeName].route, @_routes[routeName]
      # route set as default
      if @_routes[routeName].default
        $routeProvider.otherwise
          redirectTo: @_routes[routeName].route
    # make chainable
    return @

  ###*
  # @ngdoc method
  # @name kdNavProvider#addMenu
  # @param {string} menuName Name of menu
  # @param {Object} menuItems See {@link kdNavProvider#_menus}
  # @returns {kdNavProvider} Chainable Method returns reference to kdNavProvider.
  # @description
  # Setter for {@link kdNavProvider#_menus}
  ###
  @addMenu = (menuName, menuItems) ->
    @_menus._add(menuName, menuItems)
    return @

  ###*
  # @ngdoc property
  # @name kdNavProvider#$get
  # @description
  # Creates dependency-injection array to create KdNav instance.
  # Passes therefore {@link kdNavProvider#_routes} 
  # and {@link kdNavProvider#_menus} to KdNav. 
  ###
  @$get = ['$rootScope' , '$route', '$routeParams', '$location', ($rootScope, $route, $routeParams, $location) -> 
    new KdNav($rootScope, $route, $routeParams, $location, @_routes, @_menus)
  ]

  # returns provider
  return @
]) # kdNavProvider

###*
# @ngdoc type
# @name KdNav
# @param {Object} $rootScope 
# @param {Object} $route
# @param {Object} $routeParams
# @param {Object} _routes Contains the {@link kdNavProvider#_routes 'routes object'}
# @param {Object} _menus Contains the {@link kdNavProvider#_menus 'menu object'}
# @description
# Type of {@link kdNav 'kdNav-service'}
###
###*
# @ngdoc service
# @name kdNav
# @requires $rootScope 
# @requires $route
# @requires $routeParams
# @requires kdNavProvider#_routes
# @requires kdNavProvider#_menus
# @description
# Regenerates breadcrumbs-array on route-change.
# Provides interface methods to access and modify breadcrumbs elements.
#  
# Contains routes (route names mapped to routes), Breadcrumbs and Menu-Tree
# Provides interface-methods for access to routes, breadcrumbs and menu
# Provides methods for manipulation of breadcrumbs
# Can be injected into other Angular Modules
###
KdNav = ($rootScope, $route, $routeParams, $location, _routes, _menus) ->
  ###*
  # @ngdoc property
  # @name kdNav#_breadcrumbs
  # @description
  # Contains breadcrumbs
  # 
  # **Format:**
  # ```
  # routeName: <routeName>  # routeName to reference a route in route configuration {@link kdNavProvider#_routes} 
  # label: <label-string>   # copy of the default label from route configuration {@link kdNavProvider#_routes} 
  # params: <param object>  # params automatically inserted from $routeParams but can be modified from any controller with {@link kdNav#getBreadcrumb}
  # ```
  #
  # **Example:**
  # ```
  # _breadcrumbs = [
  #   {routeName:'home',    label:'Welcome',     params:{groupId:1}}
  #   {routeName:'groups',  label:'All Groups',  params:{groupId:1}}
  #   {routeName:'users',   label:'Admin Group', params:{groupId:1}}
  # ]
  # 
  # # corresponds to '/groups/1/users'
  #```
  ###
  @_breadcrumbs = []

  ###*
  # @ngdoc method
  # @name kdNav#getBreadcrumbs
  # @returns {Array} {@link kdNav#_breadcrumbs 'breadcrumbs array'}
  ###
  @getBreadcrumbs = -> @_breadcrumbs

  ###*
  # @ngdoc method
  # @name kdNav#getBreadcrumb
  # @param {string} routeName A route-name to reference a route from {@link kdNavProvider#_routes}
  # @returns {Object|undefined}
  ###
  @getBreadcrumb = (routeName) ->
    return item if item.routeName is routeName for item in @getBreadcrumbs()
    console.log 'no route entry for', routeName

  ###*
  # @ngdoc method
  # @name kdNav#_addBreadcrumb
  # @param {String} route Route-string, e.g. '/citites/:cityId/shops/:shopId'
  # @param {Object} params Route-params, e.g. {cityId:5, shopId:67}
  # @returns {kdNav} Chainable method
  # @description
  # Adds one breadcrumb
  ###
  @_addBreadcrumb = (route, params) ->
    # get routename by route
    for rn,conf of _routes
      routeName = rn if conf.route is route 
    # if route name is defined and not hidden
    if routeName
      # add to breadcrumbs path
      @_breadcrumbs.push
        routeName: routeName
        label: _routes[routeName].label
        params: params
    # make method chanable
    return @

  ###*
  # @ngdoc method
  # @name kdNav#_generateBreadcrumbs
  # @description
  # Thanks to Ian Walter: 
  # https://github.com/ianwalter/ng-breadcrumbs/blob/development/src/ng-breadcrumbs.js
  #
  # * Deletes all breadcrumbs.
  # * Splits current path-string to create a set of path-substrings.
  # * Compares each path-substring with configured routes.
  # * Matches then will be inserted into the current {@link kdNav#_breadcrumbs 'breadcrumbs-path').
  ###
  @_generateBreadcrumbs = ->
    # first we need to remove prior breadcrumbs 
    @_breadcrumbs = []
    # current route will be splitted by '/' into seperated path elements
    # testRouteElements array contains those elements 
    # in each iteration of following for-loop one routeElement is added to the testRouteElements
    # e.g. ['user',':userId','delete'] is equivalent to /user/:userId/delete
    testRouteElements = []
    # create array from original path
    routeElements = $route.current.originalPath.split('/')
    # remove duplicate empty string on root path
    routeElements.splice(1,1) if routeElements[1] is ''
    # if second element is empty string then current path refers to homepage
    for element in routeElements
      # add current element to search path elements
      testRouteElements.push(element)
      # creates test-route from elements of current route
      testRoute = testRouteElements.join('/') || '/'
      # try to add created route
      # if route doesn't exist _addBreadcrumb won't added testRoute
      @_addBreadcrumb(testRoute, $routeParams)

  ###*
  # @ngdoc method
  # @name kdNav#_prepareMenu
  # @param {Array} menuItems {@link kdNavProvider#_menus}
  # @param {Object} parentParams
  # @description
  # * Converts all params to string.
  # * Makes children items inherit parents parameters.
  ###
  @_prepareMenu = (menuItems, parentParams = {}) ->
    for item in menuItems
      # use default label if not defined
      item.label ?= _routes[item.routeName].label
      # convert all params to string (because routeParams are string-values and we need to check equality)
      item.params[paramName] = item.params[paramName].toString() for paramName of item.params
      # inherit parents params
      item.params = angular.extend({}, parentParams, item.params)
      # prepare children if available
      @_prepareMenu(item.children, item.params) if item.children

  ###*
  # @ngdoc method
  # @name kdNav#_parseMenu
  # @param {Array} menuItems The menu items (see {@link kNavProvider#_menus}) 
  # @description
  # Traverses menu-tree and finds current menu item 
  # dependency: prior generation of breadcrumb-list is required 
  #
  # Sets recursively all nodes to non active and non current
  # finds active menu-items in the path to current menu item 
  # a) criteria for active menu-item
  #   1. menu-item is in current breadcrumb-list
  #   2. paramValues of current menu-item equal the current routeParams
  # b) criteria for current menu-item
  #   1. a) criteria for active menu-item
  #   2. menu-item is last element of breadcrumbs
  ###
  @_parseMenu = (menuItems) =>
    for item in menuItems
      # set item as non active and non current as default
      item.active = item.current = false
      # get breadcrumbs index of current item
      breadcrumbsIndex = undefined
      @_breadcrumbs.map (bc,k) ->
        breadcrumbsIndex = k+1 if bc.routeName is item.routeName
      # compare parameter
      paramsEquals = true
      for param, value of item.params
        paramsEquals = false if value isnt $routeParams[param] 
      # check if item is in breadcrumbs-array and has the right param-values
      if breadcrumbsIndex and paramsEquals
        item.active = true
        # check if item is last element in breadcrumbs array
        if breadcrumbsIndex is @getBreadcrumbs().length
          item.current = true
      # resets children if available
      @_parseMenu(item.children, item.params) if item.children

  ###*
  # @ngdoc method
  # @name kdNav#getMenu
  # @param {string} menuName Name of menu to return.
  # @returns {Object|undefined}
  ###
  @getMenu = (menuName) ->
    console.log menuName, 'does not yet exist' if not _menus[menuName]
    menu = _menus[menuName]
    # prepare menu if not yet prepared
    if not menu.prepared
      @_prepareMenu( menu.items ) 
      menu.prepared = true
    # parse menu if not yet parsed
    if not menu.parsed
      @_parseMenu( menu.items ) 
      menu.parsed = true
    # return menu items
    return menu.items
    
  ###*
  # @ngdoc method
  # @name kdNav#addMenu
  # @param {string} menuName Name of the menu
  # @param {Array} menuItems {@link kdNavProvider#_menus}
  # @param {$scope} [$scope=false] Pass $scope if you want the menu to be deleted autmoatically on $destroy-event
  # @returns {kdNav}
  # @descripton
  # Method to add dynamic menu from controllers
  # The $routeChangeSuccess event is fired before a menu can be passed throug this method,
  # so {@link kdNav#_parseMenu} must be called directly after the menu gets prepared
  # by {@link kdNav#_prepareMenu}.
  # Creates a new child of $scope to delete the menu when controller get destroyed.
  # It could get expensive because generate menu  
  ###
  @addMenu = (menuName, menuItems, $scope = false) ->
    # use menu
    _menus._add(menuName, menuItems)
    # if scope was passed
    if $scope
      # don't keep dynamic menu when scope of current controller gets destroyed
      menuScope = $scope.$new()
      menuScope.menuName = menuName
      menuScope.$on '$destroy', (e)=>
        delete _menus[e.currentScope.menuName]
    # make chainable
    return @

  ###*
  # @ngdoc method
  # @name kdNav#createPath
  # @param {String} routeName Routename, e.g. 'citites'
  # @param {Object} params Parameter object, e.g. {countryId:5,citityId:19,shopId:1}
  # @return {String|undefined} Anchor, e.g. e.g. '#countries/5/citites/19/shops/1' or undefined if routeName is invalid   
  # @description
  # Finds route by its routeName and returns its routePath with passed param values.
  # Example:
  # ```
  # adminUserEdit.route = '/admin/groups/:groupId/users/:userId'
  #
  # kdNav.createPath('adminUserEdit', {groupId: 1, userId:7})
  # # returns '/admin/groups/1/users/7'
  # ```
  ###
  @createPath = (routeName, params) ->
    # if route exist
    if _routes[routeName]
      route = _routes[routeName].route
      route = route.replace(":#{key}", value) for key, value of params
      return "#{route}"
    console.log 'no route entry for', routeName

  ###*
  # Bind Listener
  # Creates breadcrumbs-generator-function and binds it to route-change-event
  ###
  $rootScope.$on '$routeChangeSuccess', =>
    # if current path is available (breadcrumbs generation depends on it, menu generation depends on breadcrumbs)
    if $route.current.originalPath
      # if current path is alias replace it
      for routeName, conf of _routes
        if conf.route is $route.current.originalPath and conf.forward
          # extend 
          params = angular.extend({}, $routeParams, conf.params)
          # change current path
          $location.path( @createPath(conf.forward, params) )
      # first we have to generate breadcrumbs because menu depends on them
      @_generateBreadcrumbs()
      # set all menus to not parsed
      _menus[menuName].parsed = false for menuName of _menus

  # return the service
  return @

###*
# @ngdoc directive
# @name kdNavBreadcrumbs
# @restrict AE
# @description
# Dislpays Breadcrumbs
###
kdNavModule.directive('kdNavBreadcrumbs', ['kdNav', (kdNav) ->
  directive =
    restrict: 'AE'
    transclude: true
    scope: {}
    link: (scope, el, attrs, ctrl, transcludeFn) ->
      # pass scope into ranscluded tempalte
      transcludeFn scope, (clonedTranscludedTemplate) ->
        el.append(clonedTranscludedTemplate) 
      # keep breadcrumbs up to date
      scope.$watch(
        ()-> kdNav.getBreadcrumbs()
        ()-> scope.breadcrumbs = kdNav.getBreadcrumbs()
      )
  return directive
]) # kdNavBreadcrumbs-Directive

###*
# @ngdoc directive
# @name kdNavMenu
# @restrict AE
# @property {string} kdNavMenu name of menu to display
# @description
# Displays a menu 
###
kdNavModule.directive('kdNavMenu', ['kdNav', (kdNav) ->
  directive =
    restrict: 'AE'
    transclude: true
    scope: 
      menuName: '@kdNavMenu'
    link: (scope, el, attrs, ctrl, transcludeFn) ->
      # pass scope into ranscluded tempalte
      transcludeFn scope, (clonedTranscludedTemplate) ->
        el.append(clonedTranscludedTemplate) 
      # keep menu up to date
      scope.$watch(
        ()-> kdNav.getMenu(scope.menuName)
        ()-> scope.menu = kdNav.getMenu(scope.menuName)
      )
  return directive
]) # kdNavMenu-Directive

###*
# @ngdoc directive
# @name kdNavPath
# @restrict A
# @element a
# @property {string} kdNavPath name of menu to display
# @property {object=} kdNavParams name of menu to display
# @description
# Linkbuilder directive generates path and puts it as value in href attribute on anchor tag.
# Path geneartion depends on routeName and params.
#
# **Jade-Example:**
# ```
# a(kd-nav-path='adminUserEdit', kd-nav-params='{groupId: 1, userId:7}') Label
# ```
# Result: <a href="#/admin/groups/1/users/7">Label</a> 
###
kdNavModule.directive('kdNavPath', ['kdNav', (kdNav) ->
  directive =
    restrict: 'A'
    scope:
      routeName: '@kdNavPath'
      params: '=kdNavParams'
    link: (scope, el, attr) ->
      # set href value
      updateHref = ->
        attr.$set('href', "##{kdNav.createPath(scope.routeName, scope.params)}")
      # watch params
      scope.$watch('params', updateHref, true)
  # return directive
  return directive
]) #kdNavPath-Directive