expect    = require 'expect.js'
path      = require 'path'
cheerio   = require 'cheerio'
_         = require 'lodash'

expander  = require '../src/expander'
processor = require '../src/processor'

describe 'processor', ->
  basepath = path.join __dirname, 'data'

  describe '#makeGroups', ->
    files = [
      {type: 'script', group: 'default', path: 'foo.js'}
      {type: 'script', group: 'default', path: 'bar.js'}
      {type: 'link',   group: 'default', path: 'foo.css'}
      {type: 'link',   group: 'default', path: 'bar.css'}
    ]
    expected =
      script:
        default: ['foo.js', 'bar.js']
      link:
        default: ['foo.css', 'bar.css']
    it 'should group files', ->
      result = processor.makeGroups(files)
      expect(result).to.eql expected

    it 'should keep only first', ->
      files.unshift({type: 'script', group: 'default', path: 'bar.js'})
      expected = _.extend({}, expected)
      expected.script.default = ['bar.js', 'foo.js']
      result = processor.makeGroups(files)
      expect(result).to.eql expected

  describe '#finalize', ->
