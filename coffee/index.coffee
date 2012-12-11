
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

init = require("./init").init

parse = (name) ->
  parse_result = cirru_parse read_file name
  all_lines = parse_result.all
  ret = make_list parse_result
  ret.all = parse_result.all
  ret

# functions about handling local environments
read_file = (name) -> fs.readFileSync name, "utf8"
watch = (name, fn) -> fs.watchFile name, interval: 100, fn
join = path.join
dirname = path.dirname
pwd = process.env.PWD
echo = (item) ->
  log item
  echo
concat = (arr1, arr2) -> arr1.concat arr2

# store all modules, maintained by load_require
all_libs = {}

read = (exp, scope) ->
  try
    [head, body...] = exp
    # log exp
    # log "---> head", head

    if is_arr head then head = read head, scope
    else if is_str head
      if scope[head]? then head = scope[head]
      else err "head #{head} not found"

    ret = head
    if body[0]?
      arg = body.shift()
      ret =
        if is_func head then head arg, scope
        else if is_obj head then head[arg]
        else err "strange head: #{head}"
      if body[0]?
        sub_exp = [ret].concat body
        sub_exp.n = exp.n
        ret = read sub_exp, scope
    else if is_func head
      ret = head null, scope
    # log "ret :", ret
    return ret
  catch one
    log " ▸ #{exp.n}\t: #{scope.ast.all[exp.n-1]} \t ✘ #{one}"
    err ""

# a node refers to a file, folded as a tree
load_node = (filename, parent) ->
  # log "\n----load_node::", filename

  all_libs[filename] = self = {}
  ast = parse filename

  self.update = ->
    ast.forEach (line) -> read line, self.scope
    # log "parent: ", parent
    parent.update() if parent?

  watch filename, ->
    # log "\n", all_libs
    log "\nreloading......\n"
    ast = parse filename
    self.update()

  self.scope =
    filename: filename
    echo: echo
    init: init
    read: read
    ast: ast

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
    ast.forEach (line) -> read line, self.scope

  return self.scope

exports.run = ->
  filename = process.argv[2]
  load_node (join pwd, filename)