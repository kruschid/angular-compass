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
          targetDir: "demo/lib"
          cleanup: true # both cleanBowerDir & cleanTargetDir are set to the value of cleanup.
    #
    # jade
    jade:
      compile:
        options:
          pretty: true
        files:
          'demo/index.html': 'demo/jade/*.jade'
    #
    # coffeescript
    coffee:
      compile:
        files: {
          'demo/js/app.js': 'demo/coffee/*.coffee'
          'src/js/angular-compass.js': 'src/coffee/*.coffee'
        }
    #
    # documentation generator
    # dgeni:
    #   options:
    #     basePath: './dist/javascripts'
    #   src: ['angular-kdnav.js']
    #   dest: 'api'
    #
    # uglify
    uglify:
      options:
        compress:
          drop_console: true # remove console warnings: every command starts with console.*
      kdNav:
        files:
          'src/js/angular-compass.min.js': ['src/js/angular-compass.js']
    #
    # watch
    watch:
      jade:
        files: ['demo/jade/*']
        tasks: ['jade']
      coffee:
        files: ['src/coffee/*', 'demo/coffee/*']
        tasks: ['coffee'] 
      # dgeni:
      #   files: ['dist/javascripts/angular-kdnav.js']
      #   tasks: ['dgeni']
      livereload:
        files: ['src/js/*', 'demo/js/*', 'demo/*']
        options:
          livereload: true

  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-bower-task')
  #grunt.loadNpmTasks('grunt-dgeni')
  grunt.loadNpmTasks('grunt-contrib-uglify')
