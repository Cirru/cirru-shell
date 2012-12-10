
fs = require "fs"
path = require "path"
log = console.log
err = (info) -> throw new Error info
cirru_parse = require("cirru-parser").parse
delay = (fn) -> setTimeout fn, 100
keys = (obj) ->
  for key, value of obj
    log key

is_arr = Array.isArray
is_str = (item) -> (typeof item) is "string"
is_obj = (item) -> (typeof item) is "object"
is_func = (item) -> (typeof item) is "function"

make_list = (list) ->
  ret = []
  list.map (item) ->
    if Array.isArray item
      ret.push (make_list item)
    else
      ret.n = item.n
      ret.push item.c
  ret

parse = (name) -> make_list cirru_parse read_file name

# functions about handling local environments
read_file = (name) -> fs.readFileSync name, "utf8"
watch = (name, fn) -> fs.watchFile name, interval: 100, fn
join = path.join
dirname = path.dirname
pwd = process.env.PWD
print = (item) ->
  log item
  print

# store all modules, maintained by load_require
all_libs = {}

run = (exp, scope) ->
  [head, body...] = exp
  # log exp

  if is_arr head
    head = run (head), scope
  # log "head is:", head
  if is_str head
    if scope[head]?
      ret = init = scope[head]
      if body[0]?
        # log "init", init
        ret = init body.shift()
        # log "then body:", body
        if body[0]?
          ret = run [ret].concat(body), scope
      # log "ret :", ret
      return ret
    else err "head #{head} not found"
  else if is_func head
    ret = init = head
    while body[0]?
      head = init body.shift()
      ret = run [head].concat(body), scope
    return ret
  else if is_obj head
    ret = init = head
    while body[0]?
      head = init[body.shift()]
      ret = run [head].concat(body), scope
    return ret

  else err "not an available head: #{head}"

# a node refers to a file, folded as a tree
load_node = (filename, parent) ->
  # log "\n----load_node::", filename

  all_libs[filename] = self = {}

  ast = parse filename

  self.update = ->
    ast.forEach (line) -> run line, self.scope
    # log "parent: ", parent
    parent.update() if parent?

  watch filename, ->
    # log "\n", all_libs
    log "\nreloading......\n"
    ast = parse filename
    self.update()

  self.scope =
    filename: filename
    print: print

  # called by every file to maintain global libs
  self.scope.require = load_require = (name) ->
    # log "requiring file:", name
    child = join (dirname filename), name
    unless all_libs[child]?
      # log "inspect!", all_libs[child], child, all_libs
      all_libs[child] = load_node child, self
    all_libs[child]

  do load = ->
    ast = parse filename
    ast.forEach (line) -> run line, self.scope
  return self.scope

exports.run = ->
  filename = process.argv[2]
  load_node (join pwd, filename)