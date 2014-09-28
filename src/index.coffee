_            = require 'lodash'
fs           = require 'fs'
path         = require 'path'
beautifyHtml = require('js-beautify').html

expander     = require './expander'
processor    = require './processor'

getHtml = ($, options) ->
  if options.tidy then beautifyHtml($.html()) else $.html()

exports.process = (rawHtml, options, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  options ?= {}
  options.tidy ?= true
  expander.expand rawHtml, options, ($) ->
    if options.concat
      processor.concatAndMinify $, options, ($) ->
        callback getHtml($, options)
    else
      $('*[group]').attr('group', null)
      callback getHtml($, options)

exports.processFile = (filepath, options, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  options ?= {}
  options.basepath ?= path.dirname(filepath)
  options.outdir ?= path.dirname(options.output) if options.output
  fs.readFile filepath, 'utf8', (err, rawHtml) ->
    return callback(err) if err?
    exports.process rawHtml, options, (html) ->
      if options.output
        fs.writeFile options.output, html, ->
          callback(null, html)
      else
        callback(null, html)
