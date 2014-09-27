expect   = require 'expect.js'
path     = require 'path'
fs       = require 'fs-extra'

globHtml = require '../src/index'
expander = require '../src/expander'

describe 'glob html', ->
  basepath = path.join __dirname, 'data'

  describe 'Expand mode', ->
    rawHtml = '<script glob="js/**/*.js"></script>'
    it 'should use expand behavior', (done) ->
      globHtml.process rawHtml, {basepath: basepath, tidy:false}, (html) ->
        expander.expand rawHtml, {basepath: basepath}, (expected) ->
          expect(html).to.eql(expected)
          done()

  describe 'concat mode', ->
    rawHtml = '<script glob="js/**/*.js"></script><link ref="stylesheet" glob="css/**/*.css">'
    it 'should concatenate files in groups', (done) ->
      outdir = '/tmp/globhtml-test'
      fs.ensureDirSync outdir
      options = {basepath: basepath, outdir: outdir, concat: true, minify: true}
      globHtml.process rawHtml, options, (html) ->
        done()
