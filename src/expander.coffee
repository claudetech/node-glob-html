cheerio      = require 'cheerio'
glob         = require 'glob'
path         = require 'path'
_            = require 'lodash'
S            = require 'string'
beautifyHtml = require('js-beautify').html
util         = require './util'

expandOne = ($, elem, options, callback) ->
  $elem = $(elem)
  tag = elem.name
  srcProp = util.getSrcProperty(tag)
  expr = path.join options.basepath, $elem.attr('glob')
  defaultGroup = options.group ? 'application'
  glob expr, (err, files) ->
    _.each files, (file) ->
      group = $elem.attr('group') ? defaultGroup
      filepath = S(file.replace options.basepath, '').chompLeft('/').s
      existing = $("#{tag}[group=\"#{group}\"][#{srcProp}=\"#{filepath}\"]")
      return if existing.length > 0
      $newElem = $elem.clone().attr(srcProp, filepath).attr('glob', null)
      $newElem.attr('group', defaultGroup) if options.concat && _.isEmpty($newElem.attr('group'))
      $elem.before $.html($newElem)
    $elem.remove()
    callback()

getHtml = ($, options) ->
  if options.tidy then beautifyHtml($.html()) else $.html()

exports.expand = (rawHtml, options, callback) ->
  $ = cheerio.load rawHtml
  [options, callback] = [{}, options] if _.isFunction(options)
  options.basepath ?= ''
  [toGlob, count] = [$('*[glob]'), 0]
  return callback(getHtml($, options), $) if toGlob.length == 0
  toGlob.each (i, elem) ->
    expandOne $, elem, options, ->
      count += 1
      if count == toGlob.length
        callback(getHtml($, options), $)
