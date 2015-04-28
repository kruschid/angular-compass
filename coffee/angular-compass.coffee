# Relevanter Artikel über Provider:
# https://docs.angularjs.org/guide/providers
# Verwandtes Plugin:
# https://github.com/ianwalter/ng-breadcrumbs
# Verwandetes Plugin:
# https://github.com/mnitschke/angular-cc-navigation

###*
# @ngdoc module
# @name ngCompass
# @description
# # ngCompass Module
# ## Features
# * Extended route features
# * Breadcrumbs generation
# * Breadcrumbs directive
# * Static and dynamic menu generation
# * Menu directive
# * Path generation 
# * Link directive
###
ngCompassModule = angular.module('ngCompass', ['ngRoute'])

###*
# @ngdoc provider
# @name ngCompassProvider
# @requires $routeProvider
# @returns {ngCompassProvider} Returns reference to ngCompassProvider
# @description 
# Provides setters for routes- and method configuration
###
ngCompassModule.provider('ngCompass', ['$routeProvider', ($routeProvider) ->
  ###*
  # @ngdoc property
  # @name ngCompassProvider#_routes
  # @description
  # Contains route config. Each route is mapped to route name.
  #
  # **Route-Format:**
  #
  #   <routeName>: # for referencing in menu, breadcrumbs and path-directive you must define a routeName
  #     route: <route-string> 
  #     label: <label-string> # label will be used by breadcrumbs and menu directive 
  #     default: <true|false> # if true this route will be used if no route matches the current request 
  #     inherit: <routeName of other route> # inherit properties except the default property from other route
  #     
  #     ... $routeProvider.when() options. e.g.:  
  #    
  #     templateUrl: <tempalteUrl>
  #     controller: <controllerName>
  #     redirectTo: <path>
  #
  #     ... more $routeProvider options ...   
  #
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
  #     inherit: 'home' # inherit properties from home-route
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
  # @name ngCompassProvider#_menus
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
  #       routeName: <routeName>  # routeName to reference a route in route configuration {@link ngCompassProvider#_routes}
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
  #   prepared: false # true after menu was pass to {@link ngCompass#_prepareMenu} 
  #   parsed: false # true after passing mainMenu to {@link ngCompass#_parseMenu} and again false on $routeChangeSuccess
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
  # @name ngCompassProvider#_menus._add
  # @param {string} menuName Name of menu
  # @param {Object} menuItems See {@link ngCompassProvider#_menus}
  # @returns {ngCompassProvider#_menus} 
  # @description
  # Setter for {@link ngCompassProvider#_menus}
  ###
  @_menus._add = (menuName, menuItems) ->
    # output warning if item already available
    if @[menuName]
      console.log "Warning: '#{menuName}' already defined. (ngCompassProvider._menus._add)"
    # add menu to menu object
    @[menuName] =
      prepared: false
      parsed: false
      items: menuItems
    return @

  ###*
  # @ngdoc method
  # @name ngCompassProvider#configRoutes
  # @param {Object} _routes See {@link ngCompassProvider#_routes}
  # @returns {ngCompassProvider} Chainable Method returns reference to ngCompassProvider.
  # @description
  # Loops over each route definition to:
  # * implement inheritence of routes 
  # * but excludes the 'default' property from that inheritance
  # * configure routes by inserting them to $routeProvider
  # * configure 'default' route for the case that any routes don't match a request  
  ###
  @addRoutes = (_routes) ->
    for routeName of _routes
      # warn if route already exists
      if @_routes[routeName]
        console.log "Warning: '#{routeName}' already defined. (ngCompassProvider.addRoutes)"
      # if route is new
      else
        inherit = _routes[routeName].inherit
        # perform inheritance
        if _routes[inherit]?
          _routes[routeName] = angular.extend({}, _routes[inherit], _routes[routeName])
          # exculde 'default'-property from inheritance
          _routes[routeName].default = false if _routes[inherit].default
        else if inherit? 
          # warn if inherit target does not exist
          console.log "Warning: #{routeName} can't inherit from #{inherit}. Not able to found #{inherit}. (ngCompassProvider.addRoutes)"
        # register route
        $routeProvider.when _routes[routeName].route, _routes[routeName]
        # route set as default
        if _routes[routeName].default
          $routeProvider.otherwise(_routes[routeName])
        # remember route conf for menu & breadcrumbs generation but  
        @_routes[routeName] = _routes[routeName]
    # make chainable
    return @

  ###*
  # @ngdoc method
  # @name ngCompassProvider#addMenu
  # @param {string} menuName Name of menu
  # @param {Object} menuItems See {@link ngCompassProvider#_menus}
  # @returns {ngCompassProvider} Chainable Method returns reference to ngCompassProvider.
  # @description
  # Setter for {@link ngCompassProvider#_menus}
  ###
  @addMenu = (menuName, menuItems) ->
    @_menus._add(menuName, menuItems)
    return @

  ###*
  # @ngdoc property
  # @name ngCompassProvider#$get
  # @description
  # Creates dependency-injection array to create NgCompass instance.
  # Passes therefore {@link ngCompassProvider#_routes} 
  # and {@link ngCompassProvider#_menus} to NgCompass. 
  ###
  @$get = ['$rootScope' , '$route', '$routeParams', '$location', ($rootScope, $route, $routeParams, $location) -> 
    new NgCompass($rootScope, $route, $routeParams, $location, @_routes, @_menus)
  ]

  # returns provider
  return @
]) # ngCompassProvider

###*
# @ngdoc type
# @name NgCompass
# @param {Object} $rootScope 
# @param {Object} $route
# @param {Object} $routeParams
# @param {Object} _routes Contains the {@link ngCompassProvider#_routes 'routes object'}
# @param {Object} _menus Contains the {@link ngCompassProvider#_menus 'menu object'}
# @description
# Type of {@link ngCompass 'ngCompass-service'}
###
###*
# @ngdoc service
# @name ngCompass
# @requires $rootScope 
# @requires $route
# @requires $routeParams
# @requires ngCompassProvider#_routes
# @requires ngCompassProvider#_menus
# @description
# Regenerates breadcrumbs-array on route-change.
# Provides interface methods to access and modify breadcrumbs elements.
#  
# Contains routes (route names mapped to routes), Breadcrumbs and Menu-Tree
# Provides interface-methods for access to routes, breadcrumbs and menu
# Provides methods for manipulation of breadcrumbs
# Can be injected into other Angular Modules
###
NgCompass = ($rootScope, $route, $routeParams, $location, _routes, _menus) ->
  ###*
  # @ngdoc property
  # @name ngCompass#_breadcrumbs._path
  # @description
  # Contains breadcrumbs
  # 
  # **Format:**
  # ```
  # routeName: <routeName>  # routeName to reference a route in route configuration {@link ngCompassProvider#_routes} 
  # label: <label-string>   # copy of the default label from route configuration {@link ngCompassProvider#_routes} 
  # params: <param object>  # params automatically inserted from $routeParams but can be modified from any controller with {@link ngCompass#getBreadcrumb}
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
  @_breadcrumbs = {}
  @_breadcrumbs._path = []

  ###*
  # @ngdoc method
  # @name ngCompass#_breadcrumbs._add
  # @param {String} routeName Routename-string, e.g. '/citites/:cityId/shops/:shopId'
  # @returns {ngCompass} Chainable method
  # @description
  # Finds routeName for route-string passed as param.
  # Adds routeName and corresponding label to {@link ngCompass#_breadcrumbs 'breadcrumbs array'}
  ###
  @_breadcrumbs._add = (route) ->
    # get routename by route
    for rn,conf of _routes
      routeName = rn if conf.route is route 
    # if route name is defined and not hidden
    if routeName
      # add to breadcrumbs path
      @_path.push
        routeName: routeName
        label: _routes[routeName].label
        params: {} # overwrites $routeParams, can be set from a controller
    # make method chanable
    return @

  ###*
  # @ngdoc method
  # @name ngCompass#getBreadcrumbs
  # @returns {Array} {@link ngCompass#_breadcrumbs 'breadcrumbs array'}
  ###
  @getBreadcrumbs = -> @_breadcrumbs._path

  ###*
  # @ngdoc method
  # @name ngCompass#getBreadcrumb
  # @param {string} routeName A route-name to reference a route from {@link ngCompassProvider#_routes}
  # @returns {Object|undefined}
  ###
  @getBreadcrumb = (routeName) ->
    # return item
    for breadcrumb in @getBreadcrumbs()
      return breadcrumb if breadcrumb.routeName is routeName 
    # or print warning
    console.log "Warning: no route entry for '#{routeName}'. (ngCompass.getBreadcrumb)"

  ###*
  # @ngdoc method
  # @name ngCompass#_generateBreadcrumbs
  # @description
  # Thanks to Ian Walter: 
  # https://github.com/ianwalter/ng-breadcrumbs/blob/development/src/ng-breadcrumbs.js
  #
  # * Deletes all breadcrumbs.
  # * Splits current path-string to create a set of path-substrings.
  # * Compares each path-substring with configured routes.
  # * Matches then will be inserted into the current {@link ngCompass#_breadcrumbs 'breadcrumbs-path').
  ###
  @_generateBreadcrumbs = ->
    # first we need to remove prior breadcrumbs 
    @_breadcrumbs._path = []
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
      # if route doesn't exist _addBreadcrumb won't add testRoute to breadcrumbs
      @_breadcrumbs._add(testRoute)

  ###*
  # @ngdoc method
  # @name ngCompass#_prepareMenu
  # @param {Array} menuItems {@link ngCompassProvider#_menus}
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
  # @name ngCompass#_parseMenu
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
      @_breadcrumbs._path.map (bc,k) ->
        breadcrumbsIndex = k+1 if bc.routeName is item.routeName
      # do params of menuitem equals those in $routeParams?
      paramsEquals = true
      for param, value of item.params
        paramsEquals = false if value isnt $routeParams[param] 
      # check if item is in breadcrumbs-array and has the right param-values
      if breadcrumbsIndex and paramsEquals
        # set item as active
        item.active = true
        # set breadcrumbs label
        @_breadcrumbs._path[breadcrumbsIndex-1].label = item.label if item.label?
        # check if item is last element in breadcrumbs array
        if breadcrumbsIndex is @getBreadcrumbs().length
          item.current = true
      # resets children if available
      @_parseMenu(item.children, item.params) if item.children

  ###*
  # @ngdoc method
  # @name ngCompass#getMenu
  # @param {string} menuName Name of menu to return.
  # @returns {Object|undefined}
  ###
  @getMenu = (menuName) ->
    # if menu doesnt exist
    if not _menus[menuName]
      console.log "Warning: '#{menuName}' does not yet exist (ngCompass.getMenu)"
      return
    # get the menu 
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
  # @name ngCompass#addMenu
  # @param {string} menuName Name of the menu
  # @param {Array} menuItems {@link ngCompassProvider#_menus}
  # @param {$scope} [$scope=false] Pass $scope if you want the menu to be deleted autmoatically on $destroy-event
  # @returns {ngCompass}
  # @descripton
  # Method to add dynamic menu from controllers
  # The $routeChangeSuccess event is fired before a menu can be passed throug this method,
  # so {@link ngCompass#_parseMenu} must be called directly after the menu gets prepared
  # by {@link ngCompass#_prepareMenu}.
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
  # @name ngCompass#createPath
  # @param {String} routeName Routename, e.g. 'citites'
  # @param {Object} [paramsOrig={}] Parameter object, e.g. {countryId:5,citityId:19,shopId:1}
  # @return {String|undefined} Anchor, e.g. e.g. '#countries/5/citites/19/shops/1' or undefined if routeName is invalid   
  # @description
  # Finds route by its routeName and returns its routePath with passed param values.
  # Performs fallback to $routeParams if the param-object passed as argument doesn't contain the required param(s)
  #
  # ** Example: **
  # ```
  # adminUserEdit.route = '/admin/groups/:groupId/users/:userId'
  #
  # ngCompass.createPath('adminUserEdit', {groupId: 1, userId:7, search:'hello'})
  # # returns '/admin/groups/1/users/7?search=hello'
  # ```
  ###
  @createPath = (routeName, paramsOrig = {}) ->
    # avoid sideeffects (params passed by ref)
    params = angular.copy(paramsOrig)
    # if route exist
    if _routes[routeName]
      # shortcut to route
      route = _routes[routeName].route
      ###*
      # @param {string} match full placeholder, e.g. :path*, :id, :search?
      # @param {string} paramName param name, e.g. path, id, search
      # @description
      # perfoms replacement of plaveholder in routestring
      # removes params were replaced
      ###
      replacer = (match, paramName) ->
        # get param value from params-oject or from route-prams
        value = params[paramName] ? $routeParams[paramName]
        # if value exists
        if value?
          # delete value from param-object and return its value
          delete params[paramName] if params[paramName]? 
          return encodeURIComponent(value)
        # otherwise warn
        console.log "Warning: #{paramName} is undefined for route name: #{routeName}. Route: #{route}. (ngCompass.createPath)"
        return match
      # perform placeholder replacement
      route = route.replace(/(?::(\w+)(?:[\?\*])?)/g, replacer)
      # generate search string
      if not angular.equals(params, {})
        route += '?' + Object.keys(params).map((k)-> "#{ k }=#{ encodeURIComponent(params[k]) }").join('&')
      # return the route
      return route
    # route does not exist
    console.log "Warning: no route entry for '#{routeName}'. (ngCompass.createPath)"

  ###*
  # Bind Listener
  # generates breadcrumbs
  # and sets all menus as not parsed
  ###
  $rootScope.$on '$routeChangeSuccess', =>
    # if current path is available (breadcrumbs generation depends on it, menu generation depends on breadcrumbs)
    if $route.current.originalPath
      # first we have to generate breadcrumbs because menu depends on them
      @_generateBreadcrumbs()
      # set all menus to not parsed
      _menus[menuName].parsed = false for menuName of _menus

  # return the service
  return @

###*
# @ngdoc directive
# @name ngCompassBreadcrumbs
# @restrict AE
# @description
# Dislpays Breadcrumbs
###
ngCompassModule.directive('ngCompassBreadcrumbs', ['ngCompass', (ngCompass) ->
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
        ()-> ngCompass.getBreadcrumbs()
        ()-> scope.breadcrumbs = ngCompass.getBreadcrumbs()
      )
  return directive
]) # ngCompassBreadcrumbs-Directive

###*
# @ngdoc directive
# @name ngCompassMenu
# @restrict AE
# @property {string} ngCompassMenu name of menu to display
# @description
# Displays a menu 
###
ngCompassModule.directive('ngCompassMenu', ['ngCompass', (ngCompass) ->
  directive =
    restrict: 'AE'
    transclude: true
    scope: 
      menuName: '@ngCompassMenu'
    link: (scope, el, attrs, ctrl, transcludeFn) ->
      # pass scope into ranscluded tempalte
      transcludeFn scope, (clonedTranscludedTemplate) ->
        el.append(clonedTranscludedTemplate) 
      # keep menu up to date
      scope.$watch(
        ()-> ngCompass.getMenu(scope.menuName)
        ()-> scope.menu = ngCompass.getMenu(scope.menuName)
      )
  return directive
]) # ngCompassMenu-Directive

###*
# @ngdoc directive
# @name ngCompassPath
# @restrict A
# @element a
# @property {string} ngCompassPath name of menu to display
# @property {object=} ngCompassParams name of menu to display
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
ngCompassModule.directive('ngCompassPath', ['ngCompass', (ngCompass) ->
  directive =
    restrict: 'A'
    scope:
      routeName: '@ngCompassPath'
      params: '=ngCompassParams'
    link: (scope, el, attr) ->
      # set href value
      updateHref = ->
        attr.$set('href', "##{ngCompass.createPath(scope.routeName, scope.params)}")
      # watch params
      scope.$watch('params', updateHref, true)
  # return directive
  return directive
]) #ngCompassPath-Directive