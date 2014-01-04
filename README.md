# Elv.js [![Build Status](https://travis-ci.org/myme/elvis.png?branch=master)](https://travis-ci.org/myme/elvis)

## Perform release

 * Update `Release notes`
 * Bump `package.json` and `bower.json` version numbers
 * Run `npm run-script build` to update all distribution sources
 * `git tag -a <tag>` with the appropriate version number

## Release notes

### v0.2.7 (UNRELEASED)

 * Add `.bindTo` to Backbone Views

### v0.2.6 (2013-11-11)

 * Fix #10 - Several Internet Explorer 8 issues

### v0.2.5

 * Add support for "safe" strings which are not escaped

### v0.2.4

 * Flatten out nested arrays passed as child elements

### v0.2.3

 * Add support for boolean attributes

### v0.2.2

 * Change Backbone.Model API to use `.get` and `.set` for the transform
   registration methods

### v0.2.1

 * Add Backbone.Model data-binding plugin
 * Proper handling of `value` attribute
 * Add event listener function `el.on`

### v0.2.0

 * Add plugin for Backbone.Model support
 * Minor bug fixes

### v0.1.1

 * Fix issue with adding child nodes

### v0.1.0

 * Initial release
