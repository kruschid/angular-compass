# Zum Ausführen:
# "grunt" bzw. "grunt default" 
module.exports = (grunt) ->
  grunt.initConfig
    #
    # bower
    bower:
      install:
        options:
          layout: 'byComponent'
          targetDir: "lib"
          cleanup: true # both cleanBowerDir & cleanTargetDir are set to the value of cleanup.
    #
    # jade
    jade:
      compile:
        options:
          pretty: true
        files:
          'index.html': 'jade/index.jade'
    #
    # coffeescript
    coffee:
      compile:
        files: {
          'js/app.js': 'coffee/app.coffee'
          'js/angular-compass.js': 'coffee/angular-compass.coffee'
        }
    #
    # documentation generator
    # dgeni:
    #   options:
    #     basePath: './dist/javascripts'
    #   src: ['angular-kdnav.js']
    #   dest: 'api'

    #
    # watch
    watch:
      jade:
        files: ['jade/*']
        tasks: ['jade']
      coffee:
        files: ['coffee/*']
        tasks: ['coffee'] 
      # dgeni:
      #   files: ['dist/javascripts/angular-kdnav.js']
      #   tasks: ['dgeni']
      livereload:
        files: ['js/*', 'index.html']
        options:
          livereload: true

  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-bower-task')
  #grunt.loadNpmTasks('grunt-dgeni')
  grunt.loadNpmTasks('grunt-contrib-uglify')
