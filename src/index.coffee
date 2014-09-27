expander = require './expander'
_        = require 'lodash'

exports.process = (html, options, callback) ->
  [options, callback] = [{}, options] if _.isFunction(options)
  options ?= {}
  if options.concat
    html
  else
    expander.expand html, options, callback
