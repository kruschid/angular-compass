# Relevanter Artikel über Provider:
# https://docs.angularjs.org/guide/providers
# Verwandtes Plugin:
# https://github.com/ianwalter/ng-breadcrumbs
# Verwandetes Plugin:
# https://github.com/mnitschke/angular-cc-navigation

###*
# Contains routes (route names mapped to routes), Breadcrumbs and Menu-Tree
# Provides interface-methods for access to routes, breadcrumbs and menu
# Provides methods for manipulation of breadcrumbs
# Can be injected into other Angular Modules
#
# @private
# @class kdNav
###
kdNav =
  ###*
  # Contains route config. Each route is mapped to route name. Example:
  #
  #   _routes =
  #     home:
  #       route: '/'
  #       label: 'Home'
  #       templateUrl: 'home.html'
  #       controller: 'HomeCtrl'
  #       default: true
  #     cities:
  #       route: '/cities'
  #       label: 'Cities'
  #       templateUrl: 'cities.html'
  #       controller: 'CitiesCtrl'
  #     citiyDetails:
  #       route: '/cities/:cityId'
  #       label: 'Citiy-Details'
  #       templateUrl: 'city-details.html'
  #       controller: 'CityDetailsCtrl'
  #
  # Note that the home-route has the attribute 'default' with value 'true' wich means, 
  # that this route will be loaded if current route isn't valid
  #
  # @protected
  # @property _routes
  # @type Object
  ###
  _routes: {}

  ###*
  # breadcrumbs array contains breadcrumbs route Names in hierarchical order, last item is current site.
  # The path '/citites/5' corresponds to followind breadcrumbs-path
  #
  #   _breadcrumbs = [
  #     routeName: 'home'
  #     label: 'Home'
  #     params: {cityId:5}
  #     ,
  #     routeName: 'cities'
  #     label: 'Citites'
  #     params: {cityId:5}
  #     ,
  #     routeName: 'cityDetails'
  #     label: 'Citites'
  #     params: {cityId:5}
  #   ]
  #
  # @protected
  # @property _breadcrumbs
  # @type Array
  ###
  _breadcrumbs: []

  ###*
  # Contains menu-tree
  #
  #   _menu = 
  #     @TODO
  #
  # @protected
  # @property _menu
  # @type Object
  ###
  _menu: {}
  
  ###*
  # @method setRoutes
  # @param {Object} routes See {{#crossLink "kdNav/_routes:attribute"}}{{/crossLink}} 
  # @chainable
  ###
  setRoutes: (@_routes) -> @

  ###*
  # @method setMenu
  # @param {Object} menu See {{#crossLink "kdNav/_menu:attribute"}}{{/crossLink}} 
  # @chainable
  ###
  setMenu: (@_menu) -> @

  ###*
  # Deletes all breadcrumbs
  #
  # @method _resetBreadcrumbs
  # @chainable
  ###
  _resetBreadcrumbs: -> 
    @_breadcrumbs = []
    return @

  ###*
  # Adds one breadcrumb
  #
  # @method addBreadcrumb
  # @param {String} route Route-string, e.g. '/citites/:cityId/shops/:shopId'
  # @param {Object} params Route-params, e.g. {cityId:5, shopId:67}
  # @chainable
  ###
  addBreadcrumb: (route, params) ->
    # if createt search path exists in routes
    routeName = @_getRouteName(route)
    if routeName
      # add to breadcrumbs path
      @_breadcrumbs.push
        routeName: routeName
        label: @_routes[routeName].label
        params: params
    # make method chanable
    return @

  ###*
  # @method getBreadcrumbs
  # @return {Array} {{#crossLink "kdNav/_breadcrumbs:attribute"}}breadcrumbs array{{/crossLink}} 
  ###
  getBreadcrumbs: -> @_breadcrumbs

  ###*
  #
  # @return {Object|undefined}
  ###
  getBreadcrumb: (routeName) ->
    return item if item.routeName is routeName for item in @getBreadcrumbs()
    console.log "no route entry for #{routeName}"

  ###*
  #
  ###
  getMenu: (menuName) -> @_menu[menuName]

  ###*  
  # @protected
  # @method _getRouteName
  # @param {String} route Route, e.g. '/citites/5/shops/9'
  # @return {String|undefined} Route-name, e.g. 'shopDetails'
  ###
  _getRouteName: (route) ->
    for routeName, conf of @_routes
      return routeName if conf.route is route

  ###*
  # Creates breadcrumbs-generator-function and binds it to route-change-event
  # breadcrumbs-generator splits current route into components
  # and compares those components with all configured routes
  # mathes then will be inserted into the current breadcrumbs-path
  # @method bindBreadcrumbsGenerator
  # @param {Object} $rootScope
  # @param {Object} $route
  # @param {Object} $routeParams
  # @chainable
  ###
  bindBreadcrumbsGenerator: ($rootScope, $route, $routeParams) ->
    # inspired by https://github.com/ianwalter/ng-breadcrumbs
    generateBreadcrumbs = =>
      # if current path is available
      if $route.current.originalPath
        # first we need to remove prior breadcrumbs 
        @_resetBreadcrumbs()
        # current route will be splitted by '/' into seperated path elements
        # testRouteElements array contains those elements 
        # in each iteration of following for-loop one pathElement is added to the searchPathElement
        # ['user',':userId','delete'] is equivalent to /user/:userId/delete
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
          # if route doesn't exist it won't be added to breadcrumbs
          @addBreadcrumb(testRoute, $routeParams)
    # bind breadcrumbs generation to route-change-event
    $rootScope.$on('$routeChangeSuccess', generateBreadcrumbs)
    # make chainable
    return @

  ###*
  # @method bindMenuGenerator
  # @chainable
  ###
  bindMenuGenerator: ($rootScope, $route, $routeParams) ->
    ###*
    # traverses menu-tree and finds current menu item 
    # dependency: prior generation of breadcrumb-list is required 
    #
    # sets recursively all nodes to non active and non current
    # converts node-params to string
    # make children inherit parents parameters
    # also finds active menu-items in the path to current menu item 
    # a) criteria for active menu-item
    #   1. menu-item is in current breadcrumb-list
    #   2. paramValues of current menu-item equal the current routeParams
    # b) criteria for current menu-item
    #   1. a) criteria for active meni-item
    #   2. menu-item is last element of breadcrumbs
    #
    # @private
    # @method traverseMenu
    # @param {Array} nodeList 
    # @param {Object} parentParams 
    # @return {Boolean} 
    ###
    traverseMenu = (nodeList, parentParams = {}) =>
      for node in nodeList
        # set node as non active and non current as default
        node.active = node.current = false
        ######### the following code should be executed only once on initialization process #########
        # use default label if not defined
        node.label ?= @_routes[node.routeName].label
        # convert all params to string (because routeParams are string-values and we need to check equality)
        node.params[paramName] = node.params[paramName].toString() for paramName of node.params
        # inherit parents params
        node.params = angular.extend({}, parentParams, node.params)
        ######### the code above should be executed only once on initialization process #########
        # get breadcrumbs index of node
        breadcrumbsIndex = undefined
        @getBreadcrumbs().map (bc,k) ->
          breadcrumbsIndex = k+1 if bc.routeName is node.routeName
        # compare parameter
        paramsEquals = true
        for param, value of node.params
          paramsEquals = false if value isnt $routeParams[param] 
        # check if node is in breadcrumbs-array and has the right param-values
        if breadcrumbsIndex and paramsEquals
          node.active = true
          # check if node is last element in breadcrumbs array
          if breadcrumbsIndex is @getBreadcrumbs().lenght
            node.current = true
        # resets children if available
        traverseMenu(node.children, node.params) if node.children
    # listener 
    generateMenu = =>
      # if current path is available
      if $route.current.originalPath
        # find current menut item and active path
        traverseMenu(@_menu[menuName]) for menuName of @_menu
    # bind breadcrumbs generation to route-change-event
    $rootScope.$on('$routeChangeSuccess', generateMenu)
    # make chainable
    return @

  ###*
  # finds route by its routeName and returns its routePath with passed param values
  #
  # @method getLink
  # @param {String} routeName Routename, e.g. 'citites'
  # @param {Object} params Parameter object, e.g. {countryId:5,citityId:19,shopId:1}
  # @return {String|undefined} Anchor, e.g. e.g. '#countries/5/citites/19/shops/1' or undefined if routeName is invalid 
  ###
  getLink: (routeName, params) ->
    # if route exist
    if @_routes[routeName]
      route = @_routes[routeName].route
      route = route.replace(":#{key}", value) for key, value of params
      return "##{route}"
    else
      console.log "no route entry for #{routeName}"

###*
# Contains configuration methods for routes and menu
# @private
# @class kdNavProvider
###
kdNavProvider =
  ###*
  # Configures routes by inserting them to $routeProvider
  #
  # @method configRoutes
  # @param {Object} $routeProvider
  # @param {Object} routes See {{#crossLink "kdNav/_routes:attribute"}}{{/crossLink}} 
  # @chainable
  ###
  configRoutes: ($routeProvider, routes) ->
    kdNav.setRoutes(routes)
    # register routes
    for routeName, conf of routes
      $routeProvider.when conf.route,
        templateUrl: conf.templateUrl
        controller: conf.controller
      # route set as default
      if conf.default
        $routeProvider.otherwise
          redirectTo: conf.route
    return @
  
  ###*
  # Configures menu
  #
  # @method configMenu
  # @param {Object} menu See {{#crossLink "kdNav/_menu:attribute"}}{{/crossLink}} 
  # @chainable
  ###
  configMenu: (menu) -> 
    kdNav.setMenu(menu)
    return @
  
  ###*
  # $get method
  ###
  $get: ['$rootScope' , '$route', '$routeParams', ($rootScope, $route, $routeParams) -> 
    kdNav.bindBreadcrumbsGenerator($rootScope, $route, $routeParams)
    kdNav.bindMenuGenerator($rootScope, $route, $routeParams)
    return kdNav
  ]

###*
# Breadcrumbs Directive
###
kdNavBreadcrumbsDirective = (kdNav) ->
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

###*
# MenuDirective
###
kdNavMenuDirective = (kdNav) ->
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
###*
# Linkbuilder directive (funktioniert derzeit nur bei Anchor-Tags)
# Verwendung:
# <a mbc-link-builder="cameraEditor" mbc-link-params="{id:5}">Label</a>
# erzeugt z.B.:
# <a href="#/cameraEditor/5">Label</a>
# falls zugehörige Route folgendermapen aussieht:
# cameraEditor: '/cameraEditor/:id'
###
kdNavLinkTargetDirective = (kdNav) ->
  directive =
    restrict: 'A'
    scope:
      routeName: '@kdNavLinkTarget'
      params: '=kdNavLinkParams'
    link: (scope, el, attr) ->
      # set href value
      updateHref = ->
        attr.$set('href', kdNav.getLink(scope.routeName, scope.params))
      # watch params
      scope.$watch('params', updateHref, true)
  # return directive
  return directive

# define controller module 
angular.module('kdNav', ['ngRoute']) 
.provider('kdNav', kdNavProvider)
.directive('kdNavBreadcrumbs', ['kdNav', kdNavBreadcrumbsDirective])
.directive('kdNavMenu', ['kdNav', kdNavMenuDirective])
.directive('kdNavLinkTarget', ['kdNav', kdNavLinkTargetDirective])