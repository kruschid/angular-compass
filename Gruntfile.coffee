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
    # watch
    watch:
      jade:
        files: ['src/jade/*.jade']
        tasks: ['jade']
      coffee:
        files: ['src/coffeescript/*.coffee']
        tasks: ['coffee'] 
      livereload:
        files: ['dist/**/*']
        options:
          livereload: true
    #
    # connect server
    connect:
      server:
        options:
          port: 9000
          base: 'dist'

  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-bower-task')
  grunt.loadNpmTasks('grunt-contrib-connect')

  grunt.registerTask('install', ['bower:install'])
  grunt.registerTask('compile', ['install', 'jade', 'coffee'])
  grunt.registerTask('run', ['connect', 'watch'])