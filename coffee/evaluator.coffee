
parse = (require 'cirru-parser').parseShort

context = {}

isExpression = (x) ->
  Array.isArray x
isToken = (x) ->
  typeof x is 'string'
isArray = (x) ->
  Array.isArray x

exports.candidates = []

exports.call = (scope, code) ->
  scope or= context
  ast = (parse code)[0]
  call scope, ast

call = (scope, expression) ->
  func = expression[0]
  args = expression[1..]
  setTimeout ->
    updateCandidate()
  , 0

  if not func?
    throw new Error "(#{expression}) not found"
  else if registry[func]?
    registry[func] context, args...
  else
    throw new Error "(#{func}) not found in (#{expression})"

readToken = (scope, name) ->
  if isToken name
    scope[name]
  else
    throw new Error "(#{name}) not found in (#{scope})"

read = (scope, item) ->
  if isToken item
    readToken item
  else
    call scope, item

prettify = (data) ->
  console.log 'prettify data'

registry =
  number: (scope, x) ->
    Number x
  string: (xs...) ->
    xs.join(' ')
  array: (scope, xs...) ->
    xs.map (item) -> read scope, item

  set: (scope, key, exp) ->
    unless (isToken key)
      throw new Error "(#{key}) is not a key in set"
    value = call scope, exp
    scope[key] = value
    value

  get: (scope, key) ->
    unless (isToken key)
      throw new Error "(#{key}) is not a key in get"
    ret = scope[key]
    ret

  print: (scope, xs...) ->
    stringList = xs
    .map (item) -> read scope, item
    .map (x) -> stringify x
    console.log stringList.join('\t')

  exit: ->
    process.exit()

do updateCandidate = ->
  exports.candidates = []
  exports.candidates = []
  .concat (Object.keys registry)
  .concat (Object.keys context)

stringify = (x) ->
  if typeof x is 'string'
    JSON.stringify x
  else if typeof x is 'number'
    x.toString()
  else if isArray x
    stringList = x.map (item) -> stringify x
    "[#{stringList.join ' '}]"
  else
    '==not implemented=='