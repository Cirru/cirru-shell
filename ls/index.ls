
require! \cirru-parser
{run} = require \./run

require! \fs

to-list = (list) ->
  list.map (item) ->
    if Array.isArray item then to-list item
    else item.line


exports.run = ->
  file-name = process.argv[2]
  code = fs.read-file-sync file-name, \utf8

  tree = to-list cirru-parser.parser code

  scope = {}
  run scope, tree