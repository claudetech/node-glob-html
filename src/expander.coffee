cheerio      = require 'cheerio'
glob         = require 'glob'
path         = require 'path'
_            = require 'lodash'
beautifyHtml = require('js-beautify').html

getSrcProperty = (tagName) ->
  switch tagName
    when 'script' then return 'src'
    when 'link' then return 'href'
    else return 'href'

expandOne = ($, elem, options, callback) ->
  $elem = $(elem)
  tag = elem.name
  srcProp = getSrcProperty(tag)
  expr = path.join options.basepath, $elem.attr('glob')
  glob expr, (err, files) ->
    _.each files, (file) ->
      filepath = file.replace options.basepath, ''
      $newElem = $elem.clone().attr(srcProp, filepath).attr('glob', null)
      $elem.before $.html($newElem)
    $elem.remove()
    callback()

exports.expand = (rawHtml, options, callback) ->
  $ = cheerio.load rawHtml
  [options, callback] = [{}, options] if _.isFunction(options)
  options.basepath ?= ''
  [toGlob, count] = [$('*[glob]'), 0]
  toGlob.each (i, elem) ->
    expandOne $, elem, options, ->
      count += 1
      if count == toGlob.length
        html = if options.tidy then beautifyHtml($.html()) else $.html()
        callback(html)
