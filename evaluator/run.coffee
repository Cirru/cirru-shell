
method = {}
log = console.log
fs = require "fs"

is_arr = Array.isArray

process.on "message", (json) ->
  log "runner message:", json
  try
    method[json.type]? json.data
  catch error
    log "runner err:", error
    process.send type: "error", error: error
process.on "exit", -> log "gone"
send = (type, data) -> process.send {type, data}

defined =
  echo: (scope, list) -> log list
  import: (scope, list) ->
    send "import", list[0]
    method.export = (scope) ->
      log scope
  set: (scope, list) ->
    scope[list[0]] = list[1]
    scope

run = (scope, list, callback) ->
  log "got:", list
  if defined[list[0]]?
    defined[list[0]] scope, list[1..]
  else log "not found:", list[0]
  callback()

list = []

evaluate = (callback) ->
  log "load:", list
  do begin = ->
    exp = list.shift()
    if exp?
      run defined, exp, begin
    else
      callback defined
  

method.import = (data) ->
  log "from runner", data
  fs.readFile data.file, (err, text) ->
    list = JSON.parse(text).filter is_arr
    evaluate (scope) -> send "export", scope

method.update = ->
  evaluate (scope) -> send "update", scope