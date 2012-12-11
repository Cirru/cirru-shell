
is_arr = Array.isArray
is_str = (item) -> typeof item is 'string'
is_num = (item) -> typeof item is 'number'
is_fun = (item) -> typeof item is 'function'
is_obj = (item) -> typeof item is 'object'
gen = (item) -> JSON.stringify item, null, 2
log = console.log
err = (info) -> throw new Error info

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
  else err "can't get item: #{item}"

add = (item, scope) ->
  item.map((key) -> get key, scope).reduce (x,y) -> x + y

comment = -> comment

get_env = (item, scope) -> scope
set_env = (item, scope) ->
  for key, value of scope[item]
    scope[key] = value

fn = (item1, scope) -> (item2) ->
  # log "define fn:", item1, item2
  child = spawn scope
  if item1[0]?
    ret = (arg) ->
      key = item1.shift()
      child[key] =
        if is_str arg then scope[arg]
        else if is_arr arg then scope.read arg, scope
        else err "wrong arg #{arg} in fn"

      if item1[0]? then ret
      else get item2, child
  else -> get item2, child

do_func = (item, scope) ->
  scope.read item, scope
  do_func

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
  set
  get
  comment
  "set-env": set_env
  "get-env": get_env
  fn: fn
  do: do_func
}