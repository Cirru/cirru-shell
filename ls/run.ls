
isArr = Array.isArray
isStr = (item) -> typeof item is 'string'
isNum = (item) -> typeof item is 'number'
gen = JSON.stringify
log = ->
error = (info) -> throw new Error info

spawn = (scope) ->
  child = {}
  log 'before spawn:', (gen child)
  child.__proto__ = scope
  log 'spawn:', (gen child)
  child

read = (scope, list) ->
  log '$read:', list
  if isArr list
    head = list[0]
    name = 
      if isStr head then head
      # else if isArr head then read scope, head
      else error 'head should be string'
    scope[name] scope, list[1 to]
  else if isStr list then scope[list]
  else 'cant handle strange type'

macro = (scope, list) ->
  # log '$macro', list
  if list.length is 0 then [] else
    head = list[0]
    if head is '~not~macro'
      log '~not~macro'
      read scope, list[1 to]
    else
      ret = []
      list.forEach (item) ->
        if isStr item then ret.push item else
          ret.push (macro scope, item)
      ret

escape-function = (key, value) ->
  if typeof value is \function
    "[Function: #key]"
  else value

render-output = (item) ->
  console.log 'item:', typeof item
  if (typeof item) is \function
    item.to-string 2
  else
    JSON.stringify item, escape-function, 2

global =
  ' stdout': []
  ' clear': (scope, list) -> global[' stdout'] = []

  number: (scope, list) ->
    log 'number:', list
    head = list[0]
    Number head

  print: (scope, list) ->
    log 'print:', list
    ret = list.map (item) -> read scope, item
    console.log ret.map(render-output).join('\t')

  string: (scope, list) ->
    log 'string:', list
    head = list[0]
    String head

  list: (scope, list) ->
    log 'list:', list
    list.map (item) -> read scope, item

  json: (scope, list) ->
    log 'json:', list
    obj = {}
    list.forEach (pair) ->
      obj[pair[0]] = read scope, pair[1]
    obj

  set: (scope, list) ->
    log 'set:', list
    name = list[0]
    value = read scope, list[1]
    scope[name] = value
    value

  get: (scope, list) ->
    log 'get:', list
    name = list[0]
    scope[name]

  add: (scope, list) ->
    log 'add:', list
    data = list.map (item) -> read scope, item
    data.reduce (x, y) -> x + y

  minus: (scope, list) ->
    log 'minus:', list
    data = list.map (item) -> read scope, item
    data.reduce (x, y) -> x - y

  self: (scope, list) ->
    log 'self:', list
    scope

  under: (scope, list) ->
    log 'under:', list
    child = spawn scope
    data = read scope, list[0]
    for key, value of data
      child[key] = value
    list[1 to].forEach (item) ->
      read child, item
    child

  inside: (scope, list) ->
    child = read scope, list[0]
    child.__proto__ = scope
    list[1 to].forEach (item) ->
      read child, item
    child

  expose: (scope, list) ->
    log 'expose:', list
    name = list[0]
    func = list[1]
    scope[func] = (child, paras) ->
      scope[name] = read child, paras[0]

  define: (scope, list) ->
    log 'define:', list
    name = list[0][0]
    args = list[0][1 to]
    scope[name] = (place, paras) ->
      log "use define.d #{name}:", scope
      index = 0
      child = spawn scope
      args.forEach (item) ->
        child[item] = read place, paras[index]
        index += 1
      ret = undefined
      list[1 to].forEach (item) ->
        ret = read child, item
      ret

  task: (scope, list) ->
    log 'task:', list
    name = list[0][0]
    args = list[0][1 to]
    scope[name] = (place, paras) ->
      log "use macro #{name}:", scope
      index = 0
      child = spawn place
      args.forEach (item) ->
        child[item] = read place, paras[index]
        index += 1
      ret = undefined
      list[1 to].forEach (item) ->
        ret = read child, item
      ret

  lambda: (scope, list) ->
    log 'lambda:', list
    args = list[0]
    (place, paras) ->
      log "use lambda:", scope
      index = 0
      child = spawn scope
      args.forEach (item) ->
        child[item] = read place, paras[index]
        index += 1
      ret = undefined
      list[1 to].forEach (item) ->
        ret = read child, item
      ret

  data: (scope, item) ->
    log 'data:', item
    item

  each: (scope, list) ->
    log 'each:', list
    data = read scope, list[0]
    func = read scope, list[1]
    # log 'inspect:', data, func
    ret = undefined
    data.forEach (item) ->
      ret = func scope, [['data', item]]
    ret

  pair: (scope, list) ->
    log 'pair:', list
    data = read scope, list[0]
    func = read scope, list[1]
    for key, value of data
      ret = func scope, [['data', key], ['data', value]]
    ret

  do: (scope, list) ->
    log 'do:', list
    ret = undefined
    list.forEach (item) ->
      ret = read scope, item
    ret

  bool: (scope, list) ->
    log 'bool:', list
    value = list[0]
    if value in 'yes ok fine good true on 1'.split(' ')
      yes
    else if value in 'no false off bad 0'.split(' ')
       no
    else undefined

  if: (scope, list) ->
    log 'if:', list
    exp = list[0]
    when_yes = list[1]
    when_no =list[2]
    ret = undefined
    if read scope, exp then read scope, when_yes
    else if when_no? then read scope, when_no

  smaller: (scope, list) ->
    log 'smaller:', list
    stack = undefined
    for item in list
      num = read scope, item
      if stack?
        log 'smaller:', num, stack
        if num <= stack then return false
      stack = num
    yes

  larger: (scope, list) ->
    log 'larger:', list
    stack = undefined
    for item in list
      num = read scope, item
      if stack?
        if num >= stack then return false
      stack = num
    yes

  read: (scope, list) ->
    log 'read:', list
    value = read scope, list[0]
    log 'read value:', value
    read scope, value

  select: (scope, list) ->
    log 'select:', list
    # to get the value of a key in an object
    obj = read scope, list[0]
    point = read scope, list[1]
    point -= 1 if isNum point
    obj[point]

  put: (scope, list) ->
    log 'put:', list
    # to set a key/value an object
    obj = read scope, list[0]
    point = read scope, list[1]
    point -= 1 if isNum point
    value = read scope, list[2]
    obj[point] = value

  mess: (scope, list) ->
    log 'mess:', list
    ret = macro scope, list
    log 'mess result:', ret
    ret

  eval: (scope, list) ->
    log 'eval:', list
    value = read scope, list[0]
    read scope, (read scope, value[0])

  comment: -> ''

exports.run = (scope, list) ->
  # console.log '\nstart time:', (new Date)
  log '\nrun global:', list
  scope.__proto__ = global
  scope[' clear']()
  list.forEach (item) -> read scope, item
  # console.log 'end time:', (new Date)
  scope
