
method = {}
log = console.log
libyaml = require "libyaml"

process.on "message", (json) ->
  log "runner message:", json
  try
    method[json.type]? json.data
  catch error
    process.send type: "error", error: error
send = (type, data) ->
  process.send {type, data}

method.file = (data) ->
  log "from runner", data
  libyaml.readFile data.file, (err, list) ->
    log list[0]
    list = list[0]
    send "list", {list}

process.on "exit", ->
  log "gone"