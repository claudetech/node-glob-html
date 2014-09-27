uglifyjs   = require 'uglify-js'
_          = require 'lodash'
fs         = require 'fs'
path       = require 'path'
compressor = require 'node-minify'
async      = require 'async'

util       = require './util'

minifyDefaultOptions = ['--mangle']

exports.makeGroups = (files) ->
  groupedFiles = {}
  _.each files, (file) ->
    groupedFiles[file.type] ?= {}
    typeFiles = groupedFiles[file.type]
    typeFiles[file.group] ?= []
    groupFiles = typeFiles[file.group]
    groupFiles.push(file.path) unless file.path in groupFiles
  groupedFiles

getCompressor = (type, options) ->
  return ['no-compress', []] unless options.minify
  switch type
    when 'script' then ['uglifyjs', ['--mangle']]
    when 'link' then ['yui-css', []]
    else ['no-compress', []]

getFileExt = (type) ->
  switch type
    when 'script' then '.js'
    when 'link' then '.css'
    else ''

minify = (options, callback) ->
  _.extend(options,
    callback: (err, min) ->
      callback err, {file: options.fileOut, content: min}
  )
  new compressor.minify(options)

exports.concatenateFiles = ($, options, groupedFiles, callback) ->
  tasks = []
  _.each groupedFiles, (groups, type) ->
    _.each groups, (files, group) ->
      ext = getFileExt(type)
      ext = ".min" + ext if options.minify
      outFile = path.join(options.basepath, group + ext)
      files = _.map files, (f) -> path.join(options.basepath, f)
      [type, minifyOptions] = getCompressor(type, options) #
      tasks.push({
        type: type
        options: minifyOptions.concat(if _.isArray(options.minify) then options.minify else [])
        fileIn: files
        fileOut: outFile
      })
  async.map tasks, minify, (err, results) ->
    callback(err, results)

exports.finalize = ($, options, callback) ->
  groups = $('*[group]')
  files = _.map groups, (g) ->
    $g = $(g)
    { group: $g.attr('group'), path: $g.attr(util.getSrcProperty(g.name)), type: g.name }
  groupedFiles = exports.makeGroups files
  exports.concatenateFiles $, options, groupedFiles, (err, results) ->
    console.log results
    callback()
