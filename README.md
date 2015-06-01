# Elvis

[![Latest npm version](https://img.shields.io/npm/v/elvis.svg?style=flat)](https://www.npmjs.org/package/elvis)
[![Number of npm downloads](https://img.shields.io/npm/dm/elvis.svg?style=flat)](https://www.npmjs.org/package/elvis)
[![Build Status](https://img.shields.io/travis/myme/elvis.svg?style=flat)](https://travis-ci.org/myme/elvis)

Elvis is a JavaScript library for creating and building DOM elements programmatically. It does this using native, cross-browser APIs (`createElement` et al). Elvis works like a template library, except without having to compile templates from strings. DOM generating code must also be valid JavaScript, and it really shines when used with a transpiled language like CoffeeScript. It is inspired by template languages like Jade and HAML.

```javascript
var el = elvis;

el(document.body, [
  el('nav', el('ul', [
    el('li', el('a(href="/")',     'Home')),
    el('li', el('a(href="/news")', 'News')),
    ...
  ])),
  el('#contents', [
    el('span.my-class', 'Hello, World!')
  ])
]);
```

## Release notes

### v1.0.1 (2015-06-01)

 * Restructure project to allow for separate elvis and elvis-backbone modules.

### v1.0.0 (2015-05-29)

 * Make elvis npm compatible

### v0.3.1 (2014-02-24)

 * Call transform function with proper context
 * Handle `number` and `boolean` types equal to `string`

### v0.3.0 (2014-02-03)

 * Add support for setting `style` attributes directly and with bindings

### v0.2.7 (2014-01-06)

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

## Perform release

 * Update `Release notes`
 * Bump `package.json` and `bower.json` version numbers (also in elvis/ + elvis-backbone/)
 * Run `npm run-script build` to update all distribution sources
 * `git tag -a <tag>` with the appropriate version number
 * `npm publish` in both elvis/ + elvis-backbone/
