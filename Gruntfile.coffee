module.exports = (grunt) ->

  grunt.initConfig
    coffee:
      dist:
        files:
          'dist/elv.js': ['lib/**/*.coffee']
      test:
        files:
          'dist/elv-test.js': ['test/**/*.coffee']

    uglify:
      dist:
        files:
          'dist/elv.min.js': 'dist/elv.js'

    watch:
      test:
        files: [
          'lib/**/*.coffee'
          'test/**/*.coffee'
        ]
        tasks: ['default']

  grunt.loadNpmTasks('grunt-buster')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('test', ['coffee', 'buster'])
  grunt.registerTask('build', ['test', 'uglify'])
  grunt.registerTask('default', ['build'])
