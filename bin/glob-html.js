#!/usr/bin/env node

var minimist = require('minimist')
  , _        = require('lodash')
  , globHtml = require('../lib');


var minimistOptions = {
  boolean: ['c', 'm', 'minify-js', 'minify-css'],
  alias: {
    output: 'o',
    concat: 'c',
    minify: 'm',
    minifyCss: 'minify-css',
    minifyJs: 'minify-js',
    group: 'g'
  }
};

var argv = minimist(process.argv.slice(2), minimistOptions);
_.each(argv._, function (file) {
  globHtml.processFile(file, argv, function (err, html) {
    if (err) {
      console.log("Error while processing " + file + ":");
      console.log(err);
    } else {
      if (argv.output) {
        console.log("Saved to " + argv.output + ".");
      } else {
        console.log(html);
      }
    }
  });
});
