module.exports = (grunt) ->

  pkg = grunt.file.readJSON('package.json')
  grunt.initConfig
    meta:
      name: pkg.name
      version: pkg.version
      license: grunt.file.read('LICENSE-ISC')

    coffee:
      dist:
        files:
          'elvis/elvis.js': ['src/elvis.coffee']
          'elvis-backbone/elvis-backbone.js': ['src/elvis-backbone.coffee']

    coffeelint:
      all: [
        'src/**/*.coffee'
        'test/**/*.coffee'
      ]

    karma:
      test:
        options:
          browsers: ['PhantomJS']
          files: [
            'bower_components/jquery/jquery.js'
            'bower_components/underscore/underscore.js'
            'bower_components/backbone/backbone.js'
            'src/elvis.coffee'
            'src/elvis-backbone.coffee'
            'test/**/*.coffee'
          ]
          frameworks: ['mocha', 'chai', 'sinon-chai']
          preprocessors:
            '**/*.coffee': 'coffee'
          singleRun: true

    usebanner:
      dist:
        options:
          position: 'top'
          linebreak: true
          banner: '''
            /*
            <%= meta.name %> <%= meta.version %> -- <%= grunt.template.today("yyyy-mm-dd") %>

            <%= meta.license %>
            */
          '''
        files:
          src: [
            'elvis/*.js',
            'elvis-backbone/*.js'
          ]

    uglify:
      options:
        banner: '<%= meta.banner %>'
      dist:
        files:
          'elvis/elvis.min.js': 'elvis/elvis.js'
          'elvis-backbone/elvis-backbone.min.js': 'elvis-backbone/elvis-backbone.js'

    watch:
      test:
        files: [
          'src/**/*.coffee'
          'test/**/*.coffee'
        ]
        tasks: ['test']

  grunt.loadNpmTasks('grunt-banner')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-karma')

  grunt.registerTask('lint', ['coffeelint'])
  grunt.registerTask('test', ['lint', 'karma'])
  grunt.registerTask('build', ['test', 'coffee', 'uglify', 'usebanner'])
  grunt.registerTask('default', ['build'])
