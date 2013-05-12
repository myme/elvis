module.exports = (grunt) ->

  grunt.initConfig
    coffee:
      dist:
        files:
          'dist/elv.js': ['lib/**/*.coffee']
      test:
        files:
          'dist/elv-test.js': ['test/**/*.coffee']

    watch:
      test:
        files: [
          'lib/**/*.coffee'
          'test/**/*.coffee'
        ]
        tasks: ['default']

  grunt.loadNpmTasks('grunt-buster')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('test', ['coffee', 'buster'])
  grunt.registerTask('default', ['test'])
