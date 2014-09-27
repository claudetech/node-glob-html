#!/usr/bin/env node

var minimist = require('minimist')
  , _        = require('lodash')
  , globHtml = require('../lib');


var minimistOptions = {
  boolean: ['O', 'c', 'm'],
  alias: {
    overwrite: 'O',
    concat: 'c',
    minify: 'm'
  }
};

var argv = minimist(process.argv.slice(2), minimistOptions);

_.each(argv._, function (file) {
  globHtml.processFile(file, argv, function (err) {
    if (err) {
      console.log("Error while processing " + file + ":");
      console.log(err);
    } else {
      console.log("Processed " + file + " successfully");
    }
  });
});
