expect   = require 'expect.js'
path     = require 'path'
cheerio  = require 'cheerio'

expander = require '../src/expander'

describe 'Expander', ->
  basepath = path.join __dirname, 'data'

  hasAll = ($, tag, attrName, attrs) ->
    html = $.html()
    elems = $(tag)
    expect(elems.length).to.be attrs.length
    elems.each (i, s) ->
      expect($(s).attr(attrName)).to.eql(attrs[i])

  describe 'scripts expand', ->
    it 'should expand scripts', (done) ->
      rawHtml = '<script src="js/**/*.js" glob></script>'
      expander.expand rawHtml, {basepath: basepath, tidy: false}, ($) ->
        hasAll($, 'script', 'src', ['js/bar.js', 'js/foo.js'])
        expect($.html()).to.not.contain '\n'
        done()

    it 'should keep absolute path', (done) ->
      rawHtml = '<script src="/js/**/*.js" glob></script>'
      expander.expand rawHtml, {basepath: basepath, tidy: false}, ($) ->
        hasAll($, 'script', 'src', ['/js/bar.js', '/js/foo.js'])
        expect($.html()).to.not.contain '\n'
        done()

    it 'should add default group when concat', (done) ->
      rawHtml = '<script src="js/**/*.js" glob></script>'
      expander.expand rawHtml, {basepath: basepath, concat: true, group: 'default'}, ($) ->
        hasAll($, 'script', 'src', ['js/bar.js', 'js/foo.js'])
        hasAll($, 'script', 'group', ['default', 'default'])
        done()

    it 'should keep existing group', (done) ->
      rawHtml = '<script src="js/**/*.js" group="app" glob></script>'
      expander.expand rawHtml, {basepath: basepath, concat: true}, ($) ->
        hasAll($, 'script', 'src', ['js/bar.js', 'js/foo.js'])
        hasAll($, 'script', 'group', ['app', 'app'])
        done()

    it 'should not duplicate', (done) ->
      rawHtml = '<script src="js/foo.js" glob></script><script src="js/**/*.js" glob></script>'
      expander.expand rawHtml, {basepath: basepath}, ($) ->
        hasAll($, 'script', 'src', ['js/foo.js', 'js/bar.js'])
        done()

  describe 'stylesheets expand', ->
    rawHtml = '<link rel="stylesheet" href="css/**/*.css" glob></link>'

    it 'should expand scripts', (done) ->
      expander.expand rawHtml, {basepath: basepath}, ($) ->
        hasAll($, 'link', 'href', ['css/bar.css', 'css/foo.css'])
        done()
