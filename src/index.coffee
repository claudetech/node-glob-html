expander = require './expander'
_        = require 'lodash'

exports.process = (rawHtml, options, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  options ?= {}
  expander.expand rawHtml, options, (html) ->
    if options.concat
      # TODO: concatenate scripts
      callback html
    else
      callback html
