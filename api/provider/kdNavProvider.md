



# kdNavProvider


* [kdNav](api/./service/kdNav)








Provides setters for routes- and method configuration







## Dependencies


* $routeProvider



  

## Usage
```js
kdNavProvider();
```





### Returns

| Type | Description |
| :--: | :--: |
| kdNavProvider | <p>Returns reference to kdNavProvider</p>  |


## Methods
### _menus._add
Setter for (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_menus]


#### Parameters

| Param | Type | Details |
| :--: | :--: | :--: |
| menuName | string | <p>Name of menu</p>  |
| menuItems | Object | <p>See (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_menus]</p>  |




#### Returns</h4>

| Type | Description |
| :--: | :--: |
| kdNavProvider#_menus |  |




### configRoutes
Loops over each route definition to:
* implement inheritence of routes 
* but excludes the 'default' property from that inheritance
* configure routes by inserting them to $routeProvider
* configure 'default' route for the case that any routes don't match a request


#### Parameters

| Param | Type | Details |
| :--: | :--: | :--: |
| _routes | Object | <p>See (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_routes]</p>  |




#### Returns</h4>

| Type | Description |
| :--: | :--: |
| kdNavProvider | <p>Chainable Method returns reference to kdNavProvider.</p>  |




### addMenu
Setter for (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_menus]


#### Parameters

| Param | Type | Details |
| :--: | :--: | :--: |
| menuName | string | <p>Name of menu</p>  |
| menuItems | Object | <p>See (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_menus]</p>  |




#### Returns</h4>

| Type | Description |
| :--: | :--: |
| kdNavProvider | <p>Chainable Method returns reference to kdNavProvider.</p>  |







## Properties
### _routes

| Type | Description |
| :--: | :--: |
|  | <p>Contains route config. Each route is mapped to route name.</p> <p><strong>Route-Format:</strong></p> <pre><code>&lt;routeName&gt;: # for referencing in menu, breadcrumbs and path-directive you must define a routeName route: &lt;route-string&gt;  templateUrl: &lt;tempalteUrl&gt; controller: &lt;controllerName&gt; label: &lt;label-string&gt; # label will be used by breadcrumbs and menu directive  default: &lt;true&amp;#124;false&gt; # if true this route will be used if no route matches the current request  extend: &lt;routeName of other route&gt; # inherit properties except the default property from other route forward: &lt;routeName of other route&gt; # automatically forward to other route params: &lt;params object&gt; # here you can pass params for the route referencing by forward property </code></pre> <p><strong>Example:</strong></p> <pre><code>_routes = home: route: &#39;/&#39; label: &#39;Home&#39; templateUrl: &#39;home.html&#39; controller: &#39;HomeCtrl&#39; default: true # if a request doesnt match any route forward to this route  info: route: &#39;/info/:command&#39; label: &#39;Info&#39; extend: &#39;home&#39; # inherit properties from home-route baseInfo: route: &#39;/info&#39; label: &#39;Info&#39; forward: &#39;info&#39; # goto info-route if this route is requested params: {command: &#39;all&#39;} # use this params to forward to info-route </code></pre>  |
  

### _menus

| Type | Description |
| :--: | :--: |
|  | <p>Contains menu-tree</p> <p><strong>Menu format:</strong></p> <pre><code>_menus.&lt;menuName&gt; =  prepared: &lt;true&amp;#124;false&gt;      # if true then all params are converted to strings and children inherited parents params parsed: &lt;true&amp;#124;false&gt;        # true means that menu tree was parsed for active elements items: [ { routeName: &lt;routeName&gt;  # routeName to reference a route in route configuration (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_routes] label: &lt;label-string&gt;   # overwrite label defined in route-config (optional, doesn&#39;t affect labels displayed in breadcrumbs) params: &lt;params-object&gt; # parameter should be used for path generation (optional) children: [             # children and childrens children {routeName:&lt;routeName&gt;, label: ...} {routeName:&lt;routeName&gt;, children: [ {routeName: ...}    # childrens children ]} ... # more children ] } ... # more menu items ] </code></pre> <p><strong>Example:</strong></p> <pre><code>_menus.mainMenu = prepared: false # true after menu was pass to kdNav  parsed: false # true after passing mainMenu to kdNav and again false on $routeChangeSuccess items: [ {routeName:&#39;admin&#39;, children:[ {routeName:&#39;groups&#39;, children:[ {routeName:&#39;group&#39;, label:&#39;Admins&#39;, params:{groupId: 1}} {routeName:&#39;group&#39;, label:&#39;Editors&#39;, params:{groupId: 2}} ]} # groups-children ]} # admin-children {routeName:&#39;contact&#39;} {routeName:&#39;help&#39;} ] # mainMenu </code></pre>  |
  

### $get

| Type | Description |
| :--: | :--: |
|  | <p>Creates dependency-injection array to create KdNav instance. Passes therefore (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_routes]  and (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_menus] to KdNav.</p>  |
  





