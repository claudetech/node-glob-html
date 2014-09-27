_        = require 'lodash'

expander  = require './expander'
processor = require './processor'

exports.process = (rawHtml, options, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  options ?= {}
  expander.expand rawHtml, options, (html, $) ->
    if options.concat
      processor.finalize $, options, (newHtml) ->
        # TODO: concatenate scripts
        callback newHtml
    else
      callback html
