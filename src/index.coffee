_         = require 'lodash'
fs        = require 'fs'
path      = require 'path'

expander  = require './expander'
processor = require './processor'

exports.process = (rawHtml, options, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  options ?= {}
  options.tidy ?= true
  expander.expand rawHtml, options, (html, $) ->
    if options.concat
      processor.concatAndMinify $, options, (newHtml) ->
        callback newHtml
    else
      callback html

exports.processFile = (filepath, options, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  options ?= {}
  options.basepath ?= path.dirname(filepath)
  fs.readFile filepath, 'utf8', (err, rawHtml) ->
    return callback(err) if err?
    exports.process rawHtml, options, (html) ->
      if options.overwrite
        fs.writeFile filepath, html, ->
          callback(null, html)
      else
        callback(null, html)
