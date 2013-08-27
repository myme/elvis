module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    coffee:
      dist:
        files:
          'dist/<%= pkg.name %>.js': ['lib/**/*.coffee']
      test:
        files:
          'dist/<%= pkg.name %>-test.js': ['test/**/*.coffee']

    buster:
      test: {}

    uglify:
      dist:
        files:
          'dist/<%= pkg.name %>.min.js': 'dist/<%= pkg.name %>.js'

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
