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
          targetDir: 'dist/lib'
          cleanTargetDir: true
          #cleanup: true # both cleanBowerDir & cleanTargetDir are set to the value of cleanup.
    #
    # jade
    jade:
      compile:
        optins:
          pretty: true
        files: [{
          cwd: 'src/jade'
          src: '*.jade'
          dest: 'dist'
          ext: '.html' 
          expand: true
        }]
    #
    # coffeescript
    coffee:
      compile:
        expand: true
        flatten: true
        cwd: 'src/coffeescript'
        src: ['*.coffee']
        dest: 'dist/javascripts'
        ext: '.js'
    #
    # documentation generator
    dgeni:
      options:
        basePath: './dist/javascripts'
      src: ['angular-kdnav.js']
      dest: 'api'
    #
    # uglify
    uglify:
      options:
        compress:
          drop_console: true
      kdNav:
        files:
          'dist/javascripts/angular-kdnav.min.js': ['dist/javascripts/angular-kdnav.js']
    #
    # watch
    watch:
      jade:
        files: ['src/jade/*.jade']
        tasks: ['jade']
      coffee:
        files: ['src/coffeescript/*.coffee']
        tasks: ['coffee'] 
      # dgeni:
      #   files: ['dist/javascripts/angular-kdnav.js']
      #   tasks: ['dgeni']
      livereload:
        files: ['dist/**/*', 'doc/**/*']
        options:
          livereload: true

  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-bower-task')
  grunt.loadNpmTasks('grunt-dgeni')
  grunt.loadNpmTasks('grunt-contrib-uglify')
