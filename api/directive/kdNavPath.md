



# kdNavPath








Linkbuilder directive generates path and puts it as value in href attribute on anchor tag.
Path geneartion depends on routeName and params.

**Jade-Example:**
```
a(kd-nav-path='adminUserEdit', kd-nav-params='{groupId: 1, userId:7}') Label
```
Result: <a href="#/admin/groups/1/users/7">Label</a>








## Directive Info


* This directive executes at priority level 0.


## Usage



* as attribute:
    ```
    <a>
    ...
    </a>
    ```







