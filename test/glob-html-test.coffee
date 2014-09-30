expect   = require 'expect.js'
path     = require 'path'
fs       = require 'fs-extra'

globHtml = require '../src/index'
expander = require '../src/expander'

describe 'glob html', ->
  basepath = path.join __dirname, 'data'

  describe 'Expand mode', ->
    rawHtml = '<script src="js/**/*.js" glob></script>'
    it 'should use expand behavior', (done) ->
      globHtml.process rawHtml, {basepath: basepath, tidy:false}, (html) ->
        expander.expand rawHtml, {basepath: basepath}, ($) ->
          $('*[group]').attr('group', null)
          expect(html).to.eql($.html())
          done()

  describe 'concat mode', ->
    rawHtml = '<script src="js/**/*.js" glob></script><link ref="stylesheet" href="css/**/*.css" glob>'
    it 'should concatenate files in groups', (done) ->
      outdir = '/tmp/globhtml-test'
      fs.ensureDirSync outdir
      options = {basepath: basepath, outdir: outdir, concat: true, minify: true}
      globHtml.process rawHtml, options, (html) ->
        done()
