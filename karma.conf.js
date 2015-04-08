module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['browserify', 'mocha'],
    files: [
      'test/**/*-test.coffee'
    ],
    preprocessors: {
      '**/*.coffee': ['browserify']
    },
    exclude: [],
    browserify: {
      debug: true,
      transform: ['coffeeify'],
      extensions: ['.coffee']
    },
    browsers: [
      'PhantomJS'
    ],
  });
};
