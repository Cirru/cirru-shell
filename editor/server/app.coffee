
Server = require("ws").Server
ss = new Server host: "0.0.0.0", port: 2013
log = console.log
fs = require "fs"
d = __dirname
code = "#{d}/../../code"
libyaml = require "libyaml"

ss.on "connection", (ws) ->

  method = {}
  
  ws.on "message", (message) ->
    json = JSON.parse(message)
    method[json.type]? json.data

  send = (type, data) ->
    json = {type, data}
    ws.send (JSON.stringify json)

  method.reload = ->
    log "on reload"
    fs.readdir code, (err, list) ->
      throw err if err?
      send "reload", {list}

  method.open = (data) ->
    libyaml.readFile "#{code}/#{data.file}", (err, list) ->
      throw err if err?
      log "open", list
      send "open", {file: data.file, list: list[0]}

  method.save = (data) ->
    log data
    if data.file?
      libyaml.writeFile "#{code}/#{data.file}", data.list, (err) ->
        log "writeFile", err