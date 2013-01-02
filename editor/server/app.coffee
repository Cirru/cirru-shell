
Server = require("ws").Server
ss = new Server host: "0.0.0.0", port: 2013
log = console.log
fs = require "fs"
d = __dirname
code = "#{d}/../../code"

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
    fs.readFile "#{code}/#{data.file}", "utf8", (err, text) ->
      throw err if err?
      try
        list = JSON.parse text
        log "open", list
        send "open", {file: data.file, list: list}
      catch error
        log "read error", error
        send "open", {file: data.file, list: []}

  method.save = (data) ->
    if data.file?
      text = JSON.stringify data.list, null, 2
      log "text", text
      fs.writeFile "#{code}/#{data.file}", text, (err) ->
        log "writeFile", err