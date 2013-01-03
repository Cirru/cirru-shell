
fork = require 'child_process'
path = require "path"
source = (name) -> path.join __dirname, "../code/#{name}.json"
log = console.log
fs = require "fs"
delay = (t, f) -> setTimeout f, t

entry = process.argv[2]
run_file = path.join __dirname, "run.coffee"

center = {}
register = (file, json) ->
  unless center[file]? then center[file] = {}
  for key, value of json then center[file][key] = value

watch_file = (file_path, callback) ->

  runner = {}
  method = {}
  register file_path, {scope: {}, runner}

  method.error = (error) -> log "runner error:", error
  method.list = (data) -> log "list:", data.list
  method.export = (scope) ->
    register file_path, {scope}
    callback?()

  method.update = (scope) ->
    register file_path, {scope}
    parent = center[file_path].parent
    if parent?
      center[parent].runner.send {type: "update"}

  do start = ->
    runner = fork.fork run_file
    register file_path, {runner}

    runner.on "exit", -> log "exit", file_path
    runner.on "message", (json) ->
      if method[json.type]?
        method[json.type] json.data
      else log "not implelemted:", json.type

    send = (type, data) ->
      log "send", type, data
      runner.send {type, data}
    
    delay 200, -> send "import", file: file_path

    method.import = (name) ->
      log "import", name
      child_path = source name
      register child_path, {parent: file_path}
      if center[child_path]?.scope?
        send "export", center[child_path].scope
      else
        watch_file child_path,  ->
          send "export", center[child_path].scope
          
    runner

  fs.watchFile file_path, interval: 200, (curr, prev) ->
    runner.kill?()
    runner = start()
    register file_path, {runner}
    parent = center[file_path].parent
    if parent?
      center[parent].runner.send {type: "update"}

watch_file (source entry)