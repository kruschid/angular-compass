## Installation
Just open the terminal and run:

	bower install angular-compass --save
	
Or add `"angular-compass":"latest"` to your dependencies in `bower.json`.

## Demo
https://kruschid.github.io/angular-compass

## How to Build

First install the *npm* dependencies (Grunt tasks).
 
	npm install
	
After that install the *bower* dependencies (AngularJS and Bootstrap for the Demo). 
	
	grunt bower:install

Run grunt to autocompile your changes on *coffee* and *jade* files. The command also starts a *livereload* service.
	
	grunt watch
