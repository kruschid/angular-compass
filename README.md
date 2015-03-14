## Verwendung
### Routes & Menüs definieren
    navConfig = ($routeProvider, kdNavProvider) ->
      # configure routes
      kdNavProvider.configRoutes $routeProvider,
        home:
          route: '/home'
          label: 'Home'
          templateUrl: 'home.html'
          controller: 'HomeCtrl'
          default: true
        contact:
          route: '/contact'
          label: 'Contact'
          templateUrl: 'contact.html'
          controller: 'ContactCtrl'
        countires: ...
        cities: ...
        shops: ...
      # configure 
      .configMenu 
        # first menu
        mainMenu: [
          routeName: 'home'
        ,
          routeName: 'countries'
        ,
          routeName: 'contact'
        ] # mainMenu
        # second menu
        countriesMenu: [
          routeName: 'cities'
          label: 'France'
          params: {countryId: 6}
        , 
          routeName: 'cities'
          label: 'Denmark'
          params: {countryId: 10}
        ,
          routeName: 'cities'
          label: 'Germany' # overwrite default label
          params: {countryId: 1}
          children: [
            routeName: 'shops'
            label: 'Trier'
            params: {cityId: 1}
          ,
            routeName: 'shops'
            label: 'Berlin'
            params: {cityId: 2}
          ] # germany-children
        ] # countriesMenu 

    angular.module('myApp', ['kdNav'])
    .config(['$routeProvider', 'kdNavProvider', navConfig])

You can define as many menus as you want.


### Link-Builder-Directive
Now you can use the 'kd-link-builder' directive on anchor elements to generate href attribute by passing route name and params. Use the same route name as in the routes definitions.  

    a(kd-nav-link-target='city', kd-nav-link-params='{countryId: 1, cityId: 7}') Shops

Will be compiled by angular to:
      
    a(href='#/countries/1/cities/7/shops') Shops

### Breadcrumbs-Template
Use `kd-nav-breadcrumbs` directive zo display breadcrumbs. You can pass the breadcrumbs template directly into the directive.

    ol.breadcrumb(kd-nav-breadcrumbs)
      li(ng-repeat='crumb in breadcrumbs', ng-class='{active:$last}')
        a(kd-nav-link-builder='{{crumb.routeName}}', 
          kd-nav-link-params='crumb.params', 
          ng-if='!$last') {{crumb.label}}
        span(ng-if='$last') {{crumb.label}}

### Menu-Template
Use the `kd-nav-menu` directive to display a menu. Note that you have to set the menu name as attribute value to generate the corresponding menu. You can pass the menu template directly into the directive. 

    div(kd-nav-menu='countriesMenu')
      ul.nav.nav-tabs
        li(ng-repeat='item in menu', ng-class='{active: item.active}')
          a(kd-nav-link-builder='{{item.routeName}}', 
            kd-nav-link-params='item.params') {{item.label}}
      ul.nav.nav-pills(ng-repeat='item in menu', ng-show='item.children && item.active')
        li(ng-repeat='childItem in item.children', ng-class='{active: childItem.active}')
          a(kd-nav-link-builder='{{childItem.routeName}}', 
            kd-nav-link-params='childItem.params') {{childItem.label}}

### Link-Builder-Service & Breadcrumbs-Service
To generate links within controllers or to change breadcrumb labels you can use the kdNav service:

    # defines controller
    homeCtrl = ($scope, kdNav) ->
      # generate link
      $scope.cityLink = kdNav.getLink('city', {countryId: 1, cityId:7})
      # change breadcrumbs-label
      kdNav.getBreadcrumb('home').label = 'Welcome'

    # add controller to app
    angular.module('myApp', ['kdNav'])
    .controller('HomeCtrl', homeCtrl)


## Bekannte Probleme

### Mehrere Elemente auf selben Menüeben sind aktiv
**Problem:**
In meinem Menü werden zwei Elemente gleichzeitig als Aktiv markiert, wie kann das sein?

**Lösung:**
Das liegt daran, dass ein Menüelement das Vaterelement des anderen ist und somit in dessen Pfad enthalten ist. 
Beispielkonfiguration:

    kdNavProvider.configRoutes $routeProvider,
      home:
        route: '/'
        controller: 'HomeCtrl'
      contact:
        route: '/contact'
        controller: 'ContactCtrl'
    .configMenu
      mainMenu: [
        routeName: 'home'
      ,
        routeName: 'contact'
      ]

Wenn man die Home-Route nicht verändern möchte, kann das Problem mit einem einfach Workaround umgangen werden. Zuerst legt ergänzt man die Routes um einen Alias für den Home-Eintrag und verweist ihn auf den selben Controller:

    homeAlias:
      route: '/home'
      controller: 'HomeCtrl'

### Breadcrumbs entsprechen nicht der Menüstruktur
**Problem:** 
Breadcrumbs entsprechen nicht meiner Menü-Struktur!

**Lösung:**
Die Breadcrumbs werden nicht nach der Menü-Struktur erzeugt sondern auf Basis der Routes. 

Beispiel-Menükonfiguration:

    Cities -> '/countries/:countryId/cities'
      City -> '/cities/:cityId'

Weil Cities-Pfad kein Teilstring vom City-Pfad ist, ist der Breadcrumbspfad nicht wie erwartet `Cities / City`, wenn man den City-Eintrag im Menü anklickt. Zudem kommt noch das Problem, dass der obere Menülink nicht generiert werden kann, wenn man den unteren Menüeintrag aufruft. Das kann passieren wenn der Parameter `:countryId` vom City-Controller weder in `$routeParams` vorhanden ist noch explizit definiert wird.

Auch hier dient ein Alias für die City-Route als einfacher Workaround:

    Cities -> '/countries/:countryId/cities'
      CityAlias -> '/countries/:countryId/cities/:cityId'

Der Pfad von CitiyAlias is in diesem Fall konsistenter und ermöglicht eine korrekte Breadcrumbs-Generierung weil die übergeordnete Route ein Teilstring der untergeordneten ist. Der Parameter `:countryId` wird für den City-Controller nicht zwingend benötigt. Das Link-Builder-Modul erleichtert aber die Generierung der Verlinkungen. Es gewährleistet dass die Parameterwerte, welche nicht explizit gesetzt sind aus `$routeParams`verwendet werden, sofern sie vorhanden sind.
