cheerio      = require 'cheerio'
glob         = require 'glob'
path         = require 'path'
_            = require 'lodash'
S            = require 'string'
util         = require './util'

expandOne = ($, elem, options, callback) ->
  $elem = $(elem)
  tag = elem.name
  srcProp = util.getSrcProperty(tag)
  expr = path.join options.basepath, ($elem.attr(srcProp) ? $elem.attr('glob'))
  defaultGroup = options.group ? 'application'
  glob expr, (err, files) ->
    _.each files, (file) ->
      group = $elem.attr('group') ? defaultGroup
      filepath = S(file.replace options.basepath, '').chompLeft('/').s
      $existing = $("#{tag}[group=\"#{group}\"][#{srcProp}=\"#{filepath}\"]")
      return if $existing.length > 0 && !$existing.is($elem)
      $newElem = $elem.clone().attr(srcProp, filepath).attr('glob', null)
      $newElem.attr('group', defaultGroup) if _.isEmpty($newElem.attr('group'))
      $elem.before $.html($newElem)
    $elem.remove()
    callback()

exports.expand = (rawHtml, options, callback) ->
  $ = cheerio.load rawHtml, {decodeEntities: false}
  [options, callback] = [{}, options] if _.isFunction(options)
  options.basepath ?= ''
  [toGlob, count] = [$('*[glob]'), 0]
  return callback($) if toGlob.length == 0
  toGlob.each (i, elem) ->
    expandOne $, elem, options, ->
      count += 1
      if count == toGlob.length
        callback($)
