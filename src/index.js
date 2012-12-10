// Generated by CoffeeScript 1.4.0
var all_libs, cirru_parse, dirname, err, fs, is_arr, is_func, is_obj, is_str, join, load_node, log, make_list, parse, path, print, pwd, read_file, watch,
  __slice = [].slice;

fs = require("fs");

path = require("path");

log = console.log;

err = function(info) {
  throw new Error(info);
};

cirru_parse = require("cirru-parser").parse;

is_arr = Array.isArray;

is_str = function(item) {
  return (typeof item) === "string";
};

is_obj = function(item) {
  return (typeof item) === "object";
};

is_func = function(item) {
  return (typeof item) === "function";
};

make_list = function(list) {
  var ret;
  ret = [];
  list.map(function(item) {
    if (Array.isArray(item)) {
      return ret.push(make_list(item));
    } else {
      ret.n = item.n;
      return ret.push(item.c);
    }
  });
  return ret;
};

parse = function(name) {
  return make_list(cirru_parse(read_file(name)));
};

all_libs = {};

read_file = function(name) {
  return fs.readFileSync(name, "utf8");
};

watch = function(name, fn) {
  return fs.watchFile(name, {
    interval: 100
  }, fn);
};

join = path.join;

dirname = path.dirname;

pwd = process.env.PWD;

print = function(item) {
  log(item);
  return print;
};

load_node = function(filename, parent) {
  var ast, load, load_require, run, self;
  self = {};
  all_libs[filename] = self;
  load_require = function(name) {
    var child, child_file;
    child_file = join(dirname(filename), name);
    if (all_libs[child_file] == null) {
      child = load_node(child_file, self);
      all_libs[child_file] = child.scope;
    }
    return all_libs[child_file];
  };
  ast = parse(filename);
  self.update = function() {
    ast.forEach(function(line) {
      return run(line, self.scope);
    });
    if (parent != null) {
      return parent.update();
    }
  };
  self.scope = {
    require: load_require,
    filename: filename,
    print: print
  };
  load = function() {
    ast = parse(filename);
    return ast.forEach(function(line) {
      return run(line, self.scope);
    });
  };
  run = function(exp, scope) {
    var body, head, init, ret;
    head = exp[0], body = 2 <= exp.length ? __slice.call(exp, 1) : [];
    if (is_arr(head)) {
      head = run(head, scope);
    }
    if (is_str(head)) {
      if (scope[head] != null) {
        ret = init = scope[head];
        if (body[0] != null) {
          ret = init(body.shift());
          if (body[0] != null) {
            ret = run([ret].concat(body), scope);
          }
        }
        return ret;
      } else {
        return err("head " + head + " not found");
      }
    } else if (is_func(head)) {
      ret = init = head;
      while (body[0] != null) {
        head = init(body.shift());
        ret = run([head].concat(body), scope);
      }
      return ret;
    } else if (is_obj(head)) {
      ret = init = head;
      while (body[0] != null) {
        head = init[body.shift()];
        ret = run([head].concat(body), scope);
      }
      return ret;
    } else {
      return err("not an available head: " + head);
    }
  };
  watch(filename, function() {
    log("\nreloading......\n");
    load();
    if (parent != null) {
      return parent.update();
    }
  });
  load();
  return self.scope;
};

exports.run = function() {
  var filename;
  filename = process.argv[2];
  return load_node(join(pwd, filename));
};