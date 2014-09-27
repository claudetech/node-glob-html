expect   = require 'expect.js'
path     = require 'path'
cheerio  = require 'cheerio'

expander = require '../src/expander'

describe 'Expander', ->
  basepath = path.join __dirname, 'data'

  hasAll = (html, tag, attrName, attrs) ->
    $ = cheerio.load(html)
    elems = $(tag)
    expect(elems.length).to.be attrs.length
    elems.each (i, s) ->
      expect($(s).attr(attrName)).to.eql(attrs[i])

  describe 'scripts expand', ->
    rawHtml = '<script glob="js/**/*.js"></script>'
    it 'should expand scripts', (done) ->
      expander.expand rawHtml, {basepath: basepath}, (html) ->
        hasAll(html, 'script', 'src', ['js/bar.js', 'js/foo.js'])
        done()

    it 'should tidy html when option given', (done) ->
      expander.expand rawHtml, {basepath: basepath, tidy: true}, (html) ->
        hasAll(html, 'script', 'src', ['js/bar.js', 'js/foo.js'])
        expect(html).to.contain '\n'
        done()

    it 'should add default group when concat', (done) ->
      expander.expand rawHtml, {basepath: basepath, concat: true}, (html) ->
        hasAll(html, 'script', 'src', ['js/bar.js', 'js/foo.js'])
        hasAll(html, 'script', 'group', ['default', 'default'])
        done()

    it 'should keep existing group', (done) ->
      rawHtml = '<script glob="js/**/*.js" group="app"></script>'
      expander.expand rawHtml, {basepath: basepath, concat: true}, (html) ->
        hasAll(html, 'script', 'src', ['js/bar.js', 'js/foo.js'])
        hasAll(html, 'script', 'group', ['app', 'app'])
        done()

  describe 'stylesheets expand', ->
    rawHtml = '<link rel="stylesheet" glob="css/**/*.css"></link>'

    it 'should expand scripts', (done) ->
      expander.expand rawHtml, {basepath: basepath}, (html) ->
        hasAll(html, 'link', 'href', ['css/bar.css', 'css/foo.css'])
        done()
