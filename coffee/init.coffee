
is_arr = Array.isArray
is_str = (item) -> typeof item is 'string'
is_num = (item) -> typeof item is 'number'
is_fun = (item) -> typeof item is 'function'
is_obj = (item) -> typeof item is 'object'
gen = (item) -> JSON.stringify item, null, 2
err = (info) -> throw new Error info

log = -> console.log.apply console, arguments

spawn = (scope) ->
  child = {}
  child.__proto__ = scope
  child

print = (item, scope) ->
  # log "item", item
  if is_str item
    log scope[item]
  else if is_arr
    log scope.read item, scope
  else log item
  print

number = (item) -> Number item
string = (item, scope) ->
  ret =
    if is_arr item then scope.read item, scope
    else if is_str item then scope[item]
    else String item
  if is_fun ret then ret.toString 2
  else if is_obj ret then JSON.stringify ret, null, 2
  else String ret

raw = (item) -> item

set = (key, scope) -> (value) ->
  # log "--> setting:", key, value
  scope[key] = {}
  if is_str value
    scope[key] = scope[value]
  else if is_arr value
    ret = scope.read value, scope
    # log "setting ret:", ret
    scope[key] = ret
  scope[key]
get = (item, scope) ->
  if is_str item then scope[item]
  else if is_arr item then scope.read item, scope
  else if if_func item then item
  else err "can't get item: #{item}"

add = (item1, scope) -> (item2) ->
  a = get item1, scope
  b = get item2, scope
  # log "adding:", a, b
  a + b
minus = (item1, scope) -> (item2) ->
  a = get item1, scope
  b = get item2, scope
  # log "minus:", a, b
  a - b

comment = -> comment

get_env = (item, scope) -> scope
set_env = (item, scope) ->
  for key, value of scope[item]
    scope[key] = value

fn = (item1, scope) -> (item2) ->
  # log "define fn:", item1
  if item1[0]?
    do ret = (scope, item1) ->
      (arg, out_scope) ->
        child = spawn out_scope
        value = get arg, out_scope
        key = item1[0]
        child[key] = value
        # log ":::", key, value, child, arg
        if item1[1]? then ret child, item1[1..]
        else
          # log "doing function", child
          get item2, child
  else
    child = spawn scope
    get item2, child

do_func = (item, scope) ->
  scope.read item, scope
  do_func

if_func = (item1, scope) -> (item2) -> (item3) ->
  if (get item1, scope) then get item2, scope
  else get item3, scope

smaller = (item1, scope) -> (item2) ->
  a = get item1, scope
  b = get item2, scope
  # log "smaller:", a, b
  a < b

exit = -> process.exit()

exports.init = {
  is_arr: is_arr
  is_str: is_str
  is_str: is_str
  is_obj: is_obj
  is_fun: is_fun
  is_num: is_num
  print
  number
  string
  "+": add
  "-": minus
  set
  get
  comment
  "set-env": set_env
  "get-env": get_env
  fn: fn
  do: do_func
  "<": smaller
  if: if_func
  raw
  exit
}