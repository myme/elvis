module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    buster:
      all: {}

    coffee:
      dist:
        files:
          'dist/elvis.js': ['lib/elvis.coffee']
          'dist/elvis-backbone.js': ['lib/elvis-backbone.coffee']
      test:
        files: [
          expand: true
          src: '{lib,test}/elvis*.coffee'
          dest: 'tmp/'
          rename: (dest, src) ->
            filename = src.replace(/\.coffee$/, '.js')
            return dest + filename
        ]

    coffeelint:
      all: [
        'lib/**/*.coffee'
        'test/**/*.coffee'
      ]

    uglify:
      dist:
        files:
          'dist/elvis.min.js': 'dist/elvis.js'
          'dist/elvis-backbone.min.js': 'dist/elvis-backbone.js'

    watch:
      test:
        files: [
          'lib/**/*.coffee'
          'test/**/*.coffee'
        ]
        tasks: ['test']

  grunt.loadNpmTasks('grunt-buster')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')

  grunt.registerTask('lint', ['coffeelint'])
  grunt.registerTask('test', ['lint', 'coffee:test', 'buster'])
  grunt.registerTask('build', ['test', 'coffee:dist', 'uglify'])
  grunt.registerTask('default', ['build'])
