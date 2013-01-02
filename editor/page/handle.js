// Generated by CoffeeScript 1.4.0

define(function(require, exports) {
  var cirru, current_file, delay, files, log, method, q, reload, save, send, ws;
  log = function() {
    var _ref;
    return typeof console !== "undefined" && console !== null ? (_ref = console.log) != null ? typeof _ref.apply === "function" ? _ref.apply(console, arguments) : void 0 : void 0 : void 0;
  };
  delay = function(f, t) {
    return setTimeout(t, f);
  };
  q = function(query) {
    return document.querySelector(query);
  };
  cirru = require("../../../cirru-editor-2/page/editor");
  cirru.editor(q("#editor"));
  ws = new WebSocket("ws://192.168.1.19:2013");
  method = {};
  send = function(type, data) {
    var json;
    json = {
      type: type,
      data: data
    };
    return ws.send(JSON.stringify(json));
  };
  ws.onmessage = function(message) {
    var json, _name;
    json = JSON.parse(message.data);
    return typeof method[_name = json.type] === "function" ? method[_name](json.data) : void 0;
  };
  current_file = void 0;
  reload = q("#reload");
  save = q("#save");
  files = q("#tree .files");
  reload.onclick = function() {
    return send("reload", {});
  };
  save.onclick = function() {
    return send("save", {
      file: current_file,
      list: cirru.content()
    });
  };
  method.reload = function(data) {
    var list;
    list = data.list;
    log(list);
    files.innerHTML = "";
    return list.sort().map(function(file) {
      var div;
      div = document.createElement("div");
      div.className = "file";
      div.innerText = file;
      div.onclick = function() {
        var last;
        save.click();
        send("open", {
          file: file
        });
        last = q("#focus");
        if (last != null) {
          last.id = "";
        }
        return div.id = "focus";
      };
      return files.appendChild(div);
    });
  };
  method.open = function(data) {
    current_file = data.file;
    log("opening", data);
    cirru.content(data.list);
    return cirru.focus();
  };
  delay(100, function() {
    return reload.click();
  });
  return exports;
});
