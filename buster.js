var fs = require('fs');
var pkg = JSON.parse(fs.readFileSync('package.json'));

exports.tests = {
  environment: 'browser',
  sources: [ 'dist/' + pkg.name + '.js' ],
  tests: [ 'dist/**-test.js' ]
};
