
is_arr = Array.isArray
is_str = (item) -> typeof item is 'string'
is_num = (item) -> typeof item is 'number'
is_fun = (item) -> typeof item is 'function'
is_obj = (item) -> typeof item is 'object'
gen = (item) -> JSON.stringify item, null, 2
log = console.log
err = (info) -> throw new Error info

print = (item) ->
  log item
  print

exports.init = {
  print
}