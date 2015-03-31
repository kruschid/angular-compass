##Install
Just open the terminal and run:

	bower angular-kdnav --save
	
Or add `"angular-kdnav":"0.2.0"` to your dependencies in `bower.json`.

## How to Use
First create a new angular app. Of course you could use your existing app as well.

	myApp = angular.module('myApp', ['kdNav'])

Now define your routes.

	myApp.config(['kdNavProvider', (kdNavProvider) ->  
	  # set up routes
	  kdNavProvider.configRoutes
	    home:
	      route: '/'
	      label: 'Home'
	      templateUrl: 'admin.html'
	    help:
	      route: '/help/:pageId'
	      label: 'Help'
	      templateUrl: 'help.html'
	      controller: 'HelpCtrl'
	    contact:
	      route: '/contact'
	      label: 'Contact'
	      templateUrl: 'contact.html'
	    '404:
	      route: '/404'
	      templateUrl: '404.html'
	]) # config

Note that each route has a **route name**, e.g. `home` or `help `.

Now we use route names for link generation:

	<a kd-nav-path='help' 
	   kd-nav-params='{pageId:1}'>FAQ</a>

To display breadcrumbs use the breadcrumbs directive. 
Therefore pass the template directly into the directive.

	<ol kd-nav-breadcrumbs>
	  <li ng-repeat='crumb in breadcrumbs' ng-class='{active:$last}'>
	    <a kd-nav-path='{{crumb.routeName}}'
	       kd-nav-params='crumb.params'>{{crumb.label}}</a>
	  </li>
	</ol>

Now we use route names to create the `mainMenu`:

	myApp.config(['kdNavProvider', (kdNavProvider) ->
	  kdNavProvider.addMenu('mainMenu', [
	      {routeName: 'help'}
	      {routeName: 'contact'}
	  ])
	)

To display `mainMenu` use the menu directive and pass the template directly to it:

	<ul kd-nav-menu='mainMenu'>
	  <li ng-repeat='item in menu' ng-class='{active: item.active, current: item.current}'>
	    <a kd-nav-path='{{item.routeName}}'
	      kd-nav-params='item.params'>{{item.label}}</a>
	  </li>
	</ul>

## More About Breadcrumbs
Breadcrumbs generation is based on the paths you defined within you config block by calling the `kdNavProvider.configRoutes` method. So if the contact-page shows *Home / Contact* as the current breadcrumbs then your home-path `/` is a substring of `/contact`.

**Problem:** Breadcrumbs don't match my menu-structure.

**Solution:** Breadcrumbs generation isn't based on the menu structure. 
Instead route definitions specify how breadcrumbs will be nested. 
For example `home.route = '/'` is a substring of `contact.route = '/contact'` 
so the contact route is a child route of home. 
This configuration generates *Home>Contact* as your breadcrumbs path if contact is current page.

Another example: If we had the following menu structure:

	mainMenu: [{
	  routeName: 'shops',
	  children: [{routeName:'cities'}]
	}] 

You may expect your breadcrumbs to be *Shops>Cities* when your current site is *Cities*.
Instead according the route definitions your breadcrumbs is *Home>Counties>Cities*:

	# Route definitions
	home.route:      '/'
	countries.route: '/countries'
	cities.route:    '/countries/:countryId/cities'

	# resulting in: 
	# Home>Counties>Cities 

**Problem:** How to pass params to breadcrumbs and how to modify breadcrumb-labels? 

**Solution:**  You don't need explicitly pass params to breadcrumbs, 
the module takes the values from `$routeParams` service.
If you need to modify breadcrumbs you have to use the `kdNav` service.

	myApp.controller('HomeCtrl', ['$scope', 'kdNav', ($scope, kdNav) ->
	  kdNav.getBreadcrumb('home').params = {id:123}
	  kdNav.getBreadcrumb('home').label = 'Welcome'
	])

## More About Menus
There are two types of menus. The type of a menu depends on the place from where you define the menu. You can define a menu within a config block. That means the menu doesn't get deleted when you load another controller. You can also define a menu within a controller. If you pass your current `$scope` to the `kdNav.addMenu` method the menu will be destroyed like your controller on `$destroy`. If you don't pass the scope variabe to that method the menu remains in memory for the applications lifetime like you would have defined it in a config block. 

	myApp.controller('HomeCtrl', ['$scope', 'kdNav', ($scope, kdNav) ->
	  kdNav.addMenu('publicMenu', [
	    {routeName:'publicPageOne'}
	    {routeName:'publicPageTwo'}
	  ], $scope)
	])

You can define as many menus as you need. You can overwrite a existing menu by using its name again while you pass a new menu object.

	kdNav.addMenu('publicMenu', [
	  {routeName:'contact'}
	  {routeName:'help'}
	]) # don't need to pass scope again because $destroy-listener is already defined 

You may want set parameter values and overwrite labels when you define a menu:

	# group.route = '/groups/:groupId/users'
	# user.route = '/groups/:groupId/users/:userId'
	kdNavProvider.addMenu ('paramMenu', [
	  {routeName:'group', label:'AngularJS', params:{groupId:1}, children:[
	    {routeName:'user', label:'Wilhelm von Osten', params:{userId:1}}
	    {routeName:'user', label:'Clever Hans', params:{userId:2}}
	  ]}
	])

Note that children automaticly inherit parents parameters. That means that the params of the menu-item *Clever Hans* is actually `{groupId:1, userId:2}`. The children of that item would also have inherit those params.  

**Problem:** Two items are displayed as active in my menu.

**Solution:** You have added the parent item of the current site to the same menu-level. Because the parent element is within the current path it is displayed as active element.

Note the following example. `home` is parent of `contact`but both are in the same menu.
If `contact` is the current page both menu items will be displayed as active.  

	home.route ='/' # is substring of contact.route
	contact.route = '/contact'
	kdNavProvider.addMenu('mainMenu',[
	    {routeName:'home', ...}
	    {routeName:'contact', ...} 
	  ]

A good workaround is to create the route `homeAlias` wich inherit controller and templateUrl from `home`:

	kdNavProvider.configRoutes 
	  ...
	  homeAlias:  {route:'/home',    extends: 'home', ...}
	.configMenu
	  mainMenu: [
	    {routeName:'homeAlias', ...}
	    {routeName:'contact', ...} 
	  ]

##More about Links

**Problem:** The breadcrumbs concept is handy. A component is parent of antoher
component if its routepath is a substring of the others components routepath.
But it is too time-consuming to pass so many route-params to `kd-nav-path` directive.

**Solution:** You don't need to do that. The link-directive takes automatically 
values from `$routeParams`.

In the following example you may want to have `cities` as parent of `shops`.
but you may not need the `countryId` param in your `shops`-controller.

	cities.route = '/countries/:countryId/cities'
	shops.route = '/countries/:countryId/cities/:cityId/shops'

So you may think you have to pass the `countryId`-param in your controller to your template:

	<a kd-nav-path='shops' 
	   kd-nav-params='{countryId:$scope.countryId, shopId:$scope.cityId}'>...</a>

But in fact you can leave parameters you don't want to modify. 
The directive takes autmatically values from `$routeParams`-service.

**Problem:** I want to create links in a controller.

**Solution:** Use `kdNav`-service.

	myApp.controller('HomeCtrl', ['$scope', 'kdNav', ($scope, kdNav) ->
	  $scope.shopsLink = kdNav.createPath('shops', {countryId: 1, cityId:7})
	])

##More Examples
For more examples clone/download this repository and open [dist/index.html](dist/index.html). Or read the code API in [src/coffeescript/angular-kdnav.coffee](src/coffeescript/angular-kdnav.coffee) 