var fs = require('fs');
var rootPkg = require('./package.json');
var version = rootPkg.version;

var files = [
  './bower.json',
  './elvis/package.json',
  './elvis-backbone/package.json',
].forEach(function (file) {
  var pkg = require(file);
  pkg.version = version;
  fs.writeFileSync(file, JSON.stringify(pkg, null, 2));
});
