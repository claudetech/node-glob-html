expect   = require 'expect.js'
path     = require 'path'

expander = require '../src/expander'

describe 'Expander', ->
  basepath = path.join __dirname, 'data'

  describe 'scripts expand', ->
    rawHtml = '<script glob="js/**/*.js"></script>'
    it 'should expand scripts', (done) ->
      expander.expand rawHtml, {basepath: basepath}, (html) ->
        expected = '<script src="/js/bar.js"></script><script src="/js/foo.js"></script>'
        expect(html).to.eql(expected)
        done()

    it 'should tidy html when option given', (done) ->
      expander.expand rawHtml, {basepath: basepath, tidy: true}, (html) ->
        expected = '<script src="/js/bar.js"></script>\n<script src="/js/foo.js"></script>'
        expect(html).to.eql(expected)
        done()

  describe 'stylesheets expand', ->
    rawHtml = '<link rel="stylesheet" glob="css/**/*.css"></link>'

    it 'should expand scripts', (done) ->
      expander.expand rawHtml, {basepath: basepath}, (html) ->
        expected = '<link rel="stylesheet" href="/css/bar.css"><link rel="stylesheet" href="/css/foo.css">'
        expect(html).to.eql(expected)
        done()
