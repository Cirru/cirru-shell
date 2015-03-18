
parse = (require 'cirru-parser').pare
require 'shelljs/global'
renderData = require('cirru-json').generate

isExpression = (x) ->
  Array.isArray x
isToken = (x) ->
  typeof x is 'string'
isArray = (x) ->
  Array.isArray x

caret =
  stack: []
  context: {}
  methods: {}
  forward: (x) ->
    unless typeof x is 'object'
      throw new Error "(#{x}) can not be a new context"
    @stack.push @context
    @context = x
  back: ->
    if @stack.length is 0
      throw new Error 'no parent context'
    @context = @stack.pop()

exports.call = (code) ->
  ast = (parse code)[0]
  evaluate caret.context, ast

evaluate = (scope, exp) ->
  setTimeout -> updateCandidate()
  func = exp[0]
  args = exp[1..]

  if not func?
    throw new Error "(#{exp}) not found"
  else if caret.methods[func]?
    caret.methods[func] scope, args...
  else
    throw new Error "(#{func}) not found in (#{exp})"

read = (scope, item) ->
  if isToken item
    if item.match /^-?\d+(\.\d+)?$/
      Number item
    else
      scope[item]
  else
    evaluate scope, item

caret.methods =
  number: (scope, x) ->
    Number x
  string: (scope, xs...) ->
    xs.join(' ')
  array: (scope, xs...) ->
    xs.map (x) -> read scope, x

  map: (scope, xs...) ->
    ret = {}
    xs.forEach (pair) ->
      ret[pair[0]] = read scope, pair[1]
    ret

  set: (scope, key, exp) ->
    unless (isToken key)
      throw new Error "(#{key}) is not a key in set"
    scope[key] = read scope, exp

  get: (scope, key) ->
    unless (isToken key)
      throw new Error "(#{key}) is not a key in get"
    scope[key]

  print: (scope, xs...) ->
    xs
    .map (x) -> read scope, x
    .map renderData
    .join '\t'

  exit: ->
    process.exit()

  rm: (scope, xs...) ->
    rm xs...

  touch: (scope, xs...) ->
    for name in xs
      ''.to name

  ls: (scope, name) ->
    ls name

  display: (scope) ->
    Object.keys scope

  forward: (scope, name) ->
    caret.forward scope[name]

  back: ->
    caret.back()

  define: (scope, template, exps...) ->
    caret.methods[template[0]] = (outer, xs...) ->
      child = {}
      for parameter, index in template[1..]
        child[parameter] = read outer, xs[index]
      ret = undefined
      exps.forEach (exp) ->
        ret = read child, exp
      ret

  level: ->
    caret.stack.length

  '+': (scope, xs...) ->
    sum = 0
    for exp in xs
      sum += read scope, exp
    sum

  '-': (scope, xs...) ->
    sum = read scope, xs[0]
    for exp in xs[1..]
      sum -= read scope, exp
    sum

do updateCandidate = ->
  exports.candidates = []
  .concat (Object.keys caret.methods)
  .concat (Object.keys caret.context)
  .map (x) -> x + ' '
