
fs = require "fs"
path = require "path"
log = console.log
err = (info) -> throw new Error info
cirru_parse = require("cirru-parser").parse

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

# store all modules, maintained by load_require
all_libs = {}

# functions about handling local environments
read_file = (name) -> fs.readFileSync name, "utf8"
watch = (name, fn) -> fs.watchFile name, interval: 100, fn
join = path.join
dirname = path.dirname
pwd = process.env.PWD
print = (item) ->
  log item
  print

# a node refers to a file, folded as a tree
load_node = (filename, parent) ->

  self = {}
  all_libs[filename] = self

  # called by every file to maintain global libs
  load_require = (name) ->
    child_file = join (dirname filename), name
    # log "requiring:", child_file, all_libs
    unless all_libs[child_file]?
      child = load_node child_file, self
      all_libs[child_file] = child.scope
    all_libs[child_file]

  ast = parse filename

  self.update = ->
    ast.forEach (line) ->
      run line, self.scope
    parent.update() if parent?

  self.scope =
    require: load_require
    filename: filename
    print: print

  load = ->
    ast = parse filename
    ast.forEach (line) ->
      run line, self.scope

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

  watch filename, ->
    # log "\n", all_libs
    log "\nreloading......\n"
    load()
    parent.update() if parent?

  load()
  self.scope

exports.run = ->
  filename = process.argv[2]
  load_node (join pwd, filename)