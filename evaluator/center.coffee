
fork = require 'child_process'
path = require "path"
source = (name) -> path.join __dirname, "../code/#{name}.yaml"
log = console.log
fs = require "fs"
delay = (t, f) -> setTimeout f, t

name = process.argv[2]

log (source name)

center = {}

watch_file = (file_path, callback) ->
  method = {}
  runner = fork.fork (path.join __dirname, "run.coffee")

  runner.on "message", (json) ->
    method[json.type]? json.data
  send = (type, data) ->
    runner.send {type, data}

  runner.on "exit", ->
    log "exit"

  send "file", file: file_path
  log "sent"

  method.resume = callback
  method.list = (data) ->
    log "list:", data.list

  method.error = (error) ->
    log "runner error:", error

  fs.watchFile file_path, interval: 200, (curr, prev) ->
    runner.kill()
    log "killing"
    watch_file file_path, callback

watch_file (source name)