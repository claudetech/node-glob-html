# glob-html [![Build Status](https://travis-ci.org/claudetech/node-glob-html.svg?branch=master)](https://travis-ci.org/claudetech/node-glob-html)

A simple utility to expand or concatenate
glob expressions in HTML.

To avoid having to insert all scripts and stylesheets,
this tool makes the glob syntax available for both
development and production.

## Installation

### CLI installation

Run

```
$ npm install -g glob-html
```

and then use it with

```sh
$ glob-html OPTIONS file
```

For example,

```sh
$ glob-html -o dist/index.html -c -m public/index.html
```

will search for globs in `public/index.html`,
minify all files globbed and output minified versions
in `dist/js` and `dist/css`, and output the
HTML using minified versions in `dist/index.html`.

The following options are available

* concat: Should the files be concatenated. default: `false`
* minify: Should the files be minified. default: `false`
* minifyCss: Should CSS files be minified. Overrides `minify`. default: `false`
* minifyJs: Should JS files be minified. Overrides `minify`. default: `false`
* output: Where to save the output.
* tempPath: `'/tmp/'`
* tidy: Should the added HTML when expanding should be pretty formated. default: `true`
* group: The default group for globbed files. default: `'application'`
* basepath: The base path to search for globbed files. default: input file directory
* outdir: The output directory for generated CSS/JS. default: output file directory
* jsPrefix: The prefix for JS files, when saving minified output, relative to `outdir`. default: `'js'`
* cssPrefix: The prefix for CSS files, when saving minified output, relative to `outdir`. default: `'css'`

### Grunt installation

This tool is available as a grunt task.

```
$ npm install --save-dev grunt-html-glob
```

and in your Gruntfile, for example:

```javascript
module.exports = function (grunt) {
  grunt.initConfig({
    glob: {
      dev: {
        files: [{
          expand: true,
          cwd: 'public',
          src: ['**/*.html'],
          dest: 'public',
          ext: '.html'
        }]
      },
      options: {
        cssPrefix: 'stylesheets',
        jsPrefix: 'scripts'
      }
    }
  });

  grunt.loadNpmTasks('grunt-html-glob');
};
```

The options are the same as the CLI.
You can then just run the `glob` task.

```sh
$ grunt glob
```

## Basic usage

```slim
html
  head
    script(src="js/**/*.js" glob)
    link(rel="stylesheet" href="css/**/*.css" glob)
```

will become

```html
<html>
<head>
  <script src="js/app.js">
  <script src="js/other.js">
  <script src="css/main.css">
  <script src="css/other.css">
</head>
<body>
</body>
</html>
```

for development build and

```html
<html>
<head>
  <script src="js/application.min.js">
  <script src="css/application.min.css">
</head>
<body>
</body>
</html>
```

for production build, where `js/application.min.js` and
`css/application.min.css` will be concatenated and
minified versions of the globbed files.

## Files order

If alphabetical order does not fit your need, you can
use glob on single files, it will be inserted only once in the output.

```slim
html
  head
    script(src="js/this-one-is-first.js" glob)
    script(src="js/**/*.js" glob)
    link(rel="stylesheet" href="css/**/*.css" glob)
```

The files will always be concatenated in order of appearance.

## Groups

To customize the output for minified files, you can use groups.
All files in the same group will result in an output
called `GROUP_NAME.(js|css)` or `GROUP_NAME.min.(js|css)`

If not specified, the default group is `application`.
You can use name for the group, as long as it can be used as a file
name in your filesystem.

Here is an example with multiple groups:

```slim
html
  head
    script(src="js/src/app.js" group="application" glob)
    script(src="js/src/**/*.js" glob)
    script(src="js/vendors/jquery.js" group="vendors" glob)
    script(src="js/vendors/**/*.js" group="vendors" glob)
```

This will be expanded normally in development,
and will compile into `application.min.js` and `vendors.min.js`
in production.
