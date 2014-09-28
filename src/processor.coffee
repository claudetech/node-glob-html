uglifyjs   = require 'uglify-js'
_          = require 'lodash'
fs         = require 'fs-extra'
path       = require 'path'
compressor = require 'node-minify'
async      = require 'async'
S          = require 'string'

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
  fallback = ['no-compress', []]
  switch type
    when 'script'
      compress = options.minify || options.minifyJs
      if compress then ['uglifyjs', ['--mangle']] else fallback
    when 'link'
      compress = options.minify || options.minifyCss
      if compress then ['yui-css', []] else fallback
    else fallback

getFileExt = (type) ->
  switch type
    when 'script' then 'js'
    when 'link' then 'css'
    else ''

minify = (options, callback) ->
  meta = options.meta
  delete options.meta
  _.extend(options,
    callback: (err, min) ->
      callback err, _.extend(meta,
        file: options.fileOut
        content: min
      )
  )
  new compressor.minify(options)

exports.concatenateFiles = ($, options, groupedFiles, callback) ->
  tasks = []
  _.each groupedFiles, (groups, type) ->
    _.each groups, (files, group) ->
      ext = getFileExt(type)
      pathPrefix = options["#{ext}Prefix"] ? ext
      ext = "min." + ext if options.minify
      outFile = path.join(options.outdir ? options.basepath, pathPrefix, "#{group}.#{ext}")
      if fs.existsSync outFile
        fs.unlinkSync outFile
      fs.ensureDirSync(path.dirname(outFile))
      files = _.map files, (f) -> path.join(options.basepath, f)
      [minType, minifyOptions] = getCompressor(type, options)
      tasks.push({
        type: minType
        options: minifyOptions.concat(if _.isArray(options.minify) then options.minify else [])
        fileIn: files
        fileOut: outFile
        tempPath: options.tempPath ? '/tmp/'
        meta:
          type: type
          group: group
          pathPrefix: pathPrefix
      })
  async.map tasks, minify, (err, results) ->
    callback(err, results)

exports.replaceTags = ($, options, results) ->
  _.each results, (result) ->
    $elems = $("#{result.type}[group=#{result.group}]")
    if options.httpBasepath
      basepath = path.join options.httpBasepath, options.pathPrefix
    else
      basepath = options.outdir ? options.basepath
      filepath = S(result.file.replace(basepath, '')).chompLeft('/').s
    $elem = $elems.first().clone().attr(util.getSrcProperty(result.type), filepath).attr('group', null)
    $elems.first().before($.html($elem))
    $elems.remove()

exports.concatAndMinify = ($, options, callback) ->
  groups = $('*[group]')
  files = _.map groups, (g) ->
    $g = $(g)
    { group: $g.attr('group'), path: $g.attr(util.getSrcProperty(g.name)), type: g.name }
  groupedFiles = exports.makeGroups files
  exports.concatenateFiles $, options, groupedFiles, (err, results) ->
    exports.replaceTags($, options, results)
    callback($)
