// Generated by CoffeeScript 1.4.0
var all_libs, cirru_parse, concat, delay, dirname, echo, err, fs, init, is_arr, is_func, is_obj, is_str, join, keys, load_node, log, make_list, parse, path, pwd, read, read_file, watch,
  __slice = [].slice;

fs = require("fs");

path = require("path");

log = console.log;

err = function(info) {
  throw new Error(info);
};

cirru_parse = require("cirru-parser").parse;

delay = function(fn) {
  return setTimeout(fn, 100);
};

keys = function(obj) {
  var key, value, _results;
  _results = [];
  for (key in obj) {
    value = obj[key];
    _results.push(log(key));
  }
  return _results;
};

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

init = require("./init").init;

parse = function(name) {
  var all_lines, parse_result, ret;
  parse_result = cirru_parse(read_file(name));
  all_lines = parse_result.all;
  ret = make_list(parse_result);
  ret.all = parse_result.all;
  return ret;
};

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

echo = function(item) {
  log(item);
  return echo;
};

concat = function(arr1, arr2) {
  return arr1.concat(arr2);
};

all_libs = {};

read = function(exp, scope) {
  var arg, body, head, ret, sub_exp;
  try {
    head = exp[0], body = 2 <= exp.length ? __slice.call(exp, 1) : [];
    if (is_arr(head)) {
      head = read(head, scope);
    } else if (is_str(head)) {
      if (scope[head] != null) {
        head = scope[head];
      } else {
        err("head " + head + " not found");
      }
    }
    ret = head;
    if (body[0] != null) {
      arg = body.shift();
      ret = is_func(head) ? head(arg, scope) : is_obj(head) ? head[arg] : err("strange head: " + head);
      if (body[0] != null) {
        sub_exp = [ret].concat(body);
        sub_exp.n = exp.n;
        ret = read(sub_exp, scope);
      }
    } else if (is_func(head)) {
      ret = head(null, scope);
    }
    return ret;
  } catch (one) {
    log(" ▸ " + exp.n + "\t: " + scope.ast.all[exp.n - 1] + " \t ✘ " + one);
    return err("");
  }
};

load_node = function(filename, parent) {
  var ast, load, load_require, self;
  all_libs[filename] = self = {};
  ast = parse(filename);
  self.update = function() {
    ast.forEach(function(line) {
      return read(line, self.scope);
    });
    if (parent != null) {
      return parent.update();
    }
  };
  watch(filename, function() {
    log("\nreloading......\n");
    ast = parse(filename);
    return self.update();
  });
  self.scope = {
    filename: filename,
    echo: echo,
    init: init,
    read: read,
    ast: ast
  };
  self.scope.require = load_require = function(name) {
    var child;
    child = join(dirname(filename), name);
    if (all_libs[child] == null) {
      all_libs[child] = load_node(child, self);
    }
    return all_libs[child];
  };
  (load = function() {
    ast = parse(filename);
    return ast.forEach(function(line) {
      return read(line, self.scope);
    });
  })();
  return self.scope;
};

exports.run = function() {
  var filename;
  filename = process.argv[2];
  return load_node(join(pwd, filename));
};
