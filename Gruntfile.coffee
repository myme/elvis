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

    coffeelint:
      all: [
        'lib/**/*.coffee'
        'test/**/*.coffee'
      ]

    karma:
      test:
        options:
          browsers: ['PhantomJS']
          files: [
            'lib/**/*.coffee'
            'test/**/*.coffee'
          ]
          frameworks: ['mocha', 'chai', 'sinon-chai']
          singleRun: true

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
        tasks: ['test']

  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-karma')

  grunt.registerTask('lint', ['coffeelint'])
  grunt.registerTask('test', ['lint', 'karma'])
  grunt.registerTask('build', ['test', 'uglify'])
  grunt.registerTask('default', ['build'])
