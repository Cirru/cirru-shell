
define (require, exports) ->
  log = -> console?.log?.apply? console, arguments
  delay = (f, t) -> setTimeout t, f
  q = (query) -> document.querySelector query

  cirru = require("../../../cirru-editor-2/page/editor")
  cirru.editor (q "#editor")

  ws = new WebSocket "ws://192.168.1.19:2013"
  method = {}

  send = (type, data) ->
    json = {type, data}
    ws.send (JSON.stringify json)

  ws.onmessage = (message) ->
    json = JSON.parse message.data
    method[json.type]? json.data

  current_file = undefined

  reload = q "#reload"
  save = q "#save"
  files = q "#tree .files"

  reload.onclick = -> send "reload", {}

  save.onclick = ->
    send "save", {file: current_file, list: cirru.content()}

  method.reload = (data) ->
    list = data.list
    log list

    files.innerHTML = ""
    # cirru.content []

    list.sort().map (file) ->
      div = document.createElement "div"
      div.className = "file"
      div.innerText = file
      div.onclick = ->
        send "open", {file}
        last = q "#focus"
        if last? then last.id = ""
        div.id = "focus"
      files.appendChild div

  method.open = (data) ->
    current_file = data.file
    log "opening", data
    cirru.content data.list
    cirru.focus()

  delay 100, -> reload.click()

  exports