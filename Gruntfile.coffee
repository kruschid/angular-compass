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

  grunt.loadNpmTasks('grunt-bower-task')