



# kdNav


* [kdNavProvider](api/./provider/kdNavProvider)








Regenerates breadcrumbs-array on route-change.
Provides interface methods to access and modify breadcrumbs elements.
 
Contains routes (route names mapped to routes), Breadcrumbs and Menu-Tree
Provides interface-methods for access to routes, breadcrumbs and menu
Provides methods for manipulation of breadcrumbs
Can be injected into other Angular Modules







## Dependencies


* $rootScope
* $route
* $routeParams
* kdNavProvider#_routes
* kdNavProvider#_menus



  




## Methods
### getBreadcrumbs







#### Returns</h4>

| Type | Description |
| :--: | :--: |
| Array | <p>&#39;breadcrumbs array&#39;</p>  |




### getBreadcrumb



#### Parameters

| Param | Type | Details |
| :--: | :--: | :--: |
| routeName | string | <p>A route-name to reference a route from (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_routes]</p>  |




#### Returns</h4>

| Type | Description |
| :--: | :--: |
| Object&#124;undefined |  |




### _addBreadcrumb
Adds one breadcrumb


#### Parameters

| Param | Type | Details |
| :--: | :--: | :--: |
| route | String | <p>Route-string, e.g. &#39;/citites/:cityId/shops/:shopId&#39;</p>  |
| params | Object | <p>Route-params, e.g. {cityId:5, shopId:67}</p>  |




#### Returns</h4>

| Type | Description |
| :--: | :--: |
| kdNav | <p>Chainable method</p>  |




### _generateBreadcrumbs
Thanks to Ian Walter: 
https://github.com/ianwalter/ng-breadcrumbs/blob/development/src/ng-breadcrumbs.js

* Deletes all breadcrumbs.
* Splits current path-string to create a set of path-substrings.
* Compares each path-substring with configured routes.
* Matches then will be inserted into the current 'breadcrumbs-path').








### _prepareMenu
* Converts all params to string.
* Makes children items inherit parents parameters.


#### Parameters

| Param | Type | Details |
| :--: | :--: | :--: |
| menuItems | Array | <p>{@link kdNavProvider#_menus</p>  |
| parentParams | Object |  |






### _parseMenu
Traverses menu-tree and finds current menu item 
dependency: prior generation of breadcrumb-list is required 

Sets recursively all nodes to non active and non current
finds active menu-items in the path to current menu item 
a) criteria for active menu-item
  1. menu-item is in current breadcrumb-list
  2. paramValues of current menu-item equal the current routeParams
b) criteria for current menu-item
  1. a) criteria for active menu-item
  2. menu-item is last element of breadcrumbs


#### Parameters

| Param | Type | Details |
| :--: | :--: | :--: |
| menuItems | Array | <p>The menu items (see kNavProvider)</p>  |






### getMenu



#### Parameters

| Param | Type | Details |
| :--: | :--: | :--: |
| menuName | string | <p>Name of menu to return.</p>  |




#### Returns</h4>

| Type | Description |
| :--: | :--: |
| Object&#124;undefined |  |




### addMenu



#### Parameters

| Param | Type | Details |
| :--: | :--: | :--: |
| menuName | string | <p>Name of the menu</p>  |
| menuItems | Array | <p>(<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_menus]</p>  |
| $scope | $scope | <p>Pass $scope if you want the menu to be deleted autmoatically on $destroy-event</p>  |




#### Returns</h4>

| Type | Description |
| :--: | :--: |
| kdNav |  |




### createPath
Finds route by its routeName and returns its routePath with passed param values.
Example:
```
adminUserEdit.route = '/admin/groups/:groupId/users/:userId'

kdNav.createPath('adminUserEdit', {groupId: 1, userId:7})
# returns '/admin/groups/1/users/7'
```


#### Parameters

| Param | Type | Details |
| :--: | :--: | :--: |
| routeName | String | <p>Routename, e.g. &#39;citites&#39;</p>  |
| params | Object | <p>Parameter object, e.g. {countryId:5,citityId:19,shopId:1}</p>  |




#### Returns</h4>

| Type | Description |
| :--: | :--: |
| String&#124;undefined | <p>Anchor, e.g. e.g. &#39;#countries/5/citites/19/shops/1&#39; or undefined if routeName is invalid</p>  |







## Properties
### _breadcrumbs

| Type | Description |
| :--: | :--: |
|  | <p>Contains breadcrumbs</p> <p><strong>Format:</strong></p> <pre><code>routeName: &lt;routeName&gt;  # routeName to reference a route in route configuration (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_routes]  label: &lt;label-string&gt;   # copy of the default label from route configuration (<code>kdNavProvider</code>)[api/./provider/kdNavProvider#_routes]  params: &lt;param object&gt;  # params automatically inserted from $routeParams but can be modified from any controller with kdNav </code></pre> <p><strong>Example:</strong></p> <pre><code>_breadcrumbs = [ {routeName:&#39;home&#39;,    label:&#39;Welcome&#39;,     params:{groupId:1}} {routeName:&#39;groups&#39;,  label:&#39;All Groups&#39;,  params:{groupId:1}} {routeName:&#39;users&#39;,   label:&#39;Admin Group&#39;, params:{groupId:1}} ] # corresponds to &#39;/groups/1/users&#39; </code></pre>  |
  





