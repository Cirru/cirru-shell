var isArr, isStr, isNum, gen, log, error, spawn, read, macro, escapeFunction, renderOutput, global, slice$ = [].slice;
isArr = Array.isArray;
isStr = function(item){
  return typeof item === 'string';
};
isNum = function(item){
  return typeof item === 'number';
};
gen = JSON.stringify;
log = function(){};
error = function(info){
  throw new Error(info);
};
spawn = function(scope){
  var child;
  child = {};
  log('before spawn:', gen(child));
  child.__proto__ = scope;
  log('spawn:', gen(child));
  return child;
};
read = function(scope, list){
  var head, name;
  log('$read:', list);
  if (isArr(list)) {
    head = list[0];
    name = isStr(head)
      ? head
      : error('head should be string');
    return scope[name](scope, slice$.call(list, 1));
  } else if (isStr(list)) {
    return scope[list];
  } else {
    return 'cant handle strange type';
  }
};
macro = function(scope, list){
  var head, ret;
  if (list.length === 0) {
    return [];
  } else {
    head = list[0];
    if (head === '~not~macro') {
      log('~not~macro');
      return read(scope, slice$.call(list, 1));
    } else {
      ret = [];
      list.forEach(function(item){
        if (isStr(item)) {
          return ret.push(item);
        } else {
          return ret.push(macro(scope, item));
        }
      });
      return ret;
    }
  }
};
escapeFunction = function(key, value){
  if (typeof value === 'function') {
    return "[Function: " + key + "]";
  } else {
    return value;
  }
};
renderOutput = function(item){
  console.log('item:', typeof item);
  if (typeof item === 'function') {
    return item.toString(2);
  } else {
    return JSON.stringify(item, escapeFunction, 2);
  }
};
global = {
  ' stdout': [],
  ' clear': function(scope, list){
    return global[' stdout'] = [];
  },
  number: function(scope, list){
    var head;
    log('number:', list);
    head = list[0];
    return Number(head);
  },
  print: function(scope, list){
    var ret;
    log('print:', list);
    ret = list.map(function(item){
      return read(scope, item);
    });
    return console.log(ret.map(renderOutput).join('\t'));
  },
  string: function(scope, list){
    var head;
    log('string:', list);
    head = list[0];
    return String(head);
  },
  list: function(scope, list){
    log('list:', list);
    return list.map(function(item){
      return read(scope, item);
    });
  },
  json: function(scope, list){
    var obj;
    log('json:', list);
    obj = {};
    list.forEach(function(pair){
      return obj[pair[0]] = read(scope, pair[1]);
    });
    return obj;
  },
  set: function(scope, list){
    var name, value;
    log('set:', list);
    name = list[0];
    value = read(scope, list[1]);
    scope[name] = value;
    return value;
  },
  get: function(scope, list){
    var name;
    log('get:', list);
    name = list[0];
    return scope[name];
  },
  add: function(scope, list){
    var data;
    log('add:', list);
    data = list.map(function(item){
      return read(scope, item);
    });
    return data.reduce(function(x, y){
      return x + y;
    });
  },
  minus: function(scope, list){
    var data;
    log('minus:', list);
    data = list.map(function(item){
      return read(scope, item);
    });
    return data.reduce(function(x, y){
      return x - y;
    });
  },
  self: function(scope, list){
    log('self:', list);
    return scope;
  },
  under: function(scope, list){
    var child, data, key, value;
    log('under:', list);
    child = spawn(scope);
    data = read(scope, list[0]);
    for (key in data) {
      value = data[key];
      child[key] = value;
    }
    slice$.call(list, 1).forEach(function(item){
      return read(child, item);
    });
    return child;
  },
  inside: function(scope, list){
    var child;
    child = read(scope, list[0]);
    child.__proto__ = scope;
    slice$.call(list, 1).forEach(function(item){
      return read(child, item);
    });
    return child;
  },
  expose: function(scope, list){
    var name, func;
    log('expose:', list);
    name = list[0];
    func = list[1];
    return scope[func] = function(child, paras){
      return scope[name] = read(child, paras[0]);
    };
  },
  define: function(scope, list){
    var name, args;
    log('define:', list);
    name = list[0][0];
    args = slice$.call(list[0], 1);
    return scope[name] = function(place, paras){
      var index, child, ret;
      log("use define.d " + name + ":", scope);
      index = 0;
      child = spawn(scope);
      args.forEach(function(item){
        child[item] = read(place, paras[index]);
        return index += 1;
      });
      ret = void 8;
      slice$.call(list, 1).forEach(function(item){
        var ret;
        return ret = read(child, item);
      });
      return ret;
    };
  },
  task: function(scope, list){
    var name, args;
    log('task:', list);
    name = list[0][0];
    args = slice$.call(list[0], 1);
    return scope[name] = function(place, paras){
      var index, child, ret;
      log("use macro " + name + ":", scope);
      index = 0;
      child = spawn(place);
      args.forEach(function(item){
        child[item] = read(place, paras[index]);
        return index += 1;
      });
      ret = void 8;
      slice$.call(list, 1).forEach(function(item){
        var ret;
        return ret = read(child, item);
      });
      return ret;
    };
  },
  lambda: function(scope, list){
    var args;
    log('lambda:', list);
    args = list[0];
    return function(place, paras){
      var index, child, ret;
      log("use lambda:", scope);
      index = 0;
      child = spawn(scope);
      args.forEach(function(item){
        child[item] = read(place, paras[index]);
        return index += 1;
      });
      ret = void 8;
      slice$.call(list, 1).forEach(function(item){
        var ret;
        return ret = read(child, item);
      });
      return ret;
    };
  },
  data: function(scope, item){
    log('data:', item);
    return item;
  },
  each: function(scope, list){
    var data, func, ret;
    log('each:', list);
    data = read(scope, list[0]);
    func = read(scope, list[1]);
    ret = void 8;
    data.forEach(function(item){
      var ret;
      return ret = func(scope, [['data', item]]);
    });
    return ret;
  },
  pair: function(scope, list){
    var data, func, key, value, ret;
    log('pair:', list);
    data = read(scope, list[0]);
    func = read(scope, list[1]);
    for (key in data) {
      value = data[key];
      ret = func(scope, [['data', key], ['data', value]]);
    }
    return ret;
  },
  'do': function(scope, list){
    var ret;
    log('do:', list);
    ret = void 8;
    list.forEach(function(item){
      var ret;
      return ret = read(scope, item);
    });
    return ret;
  },
  bool: function(scope, list){
    var value;
    log('bool:', list);
    value = list[0];
    if (in$(value, 'yes ok fine good true on 1'.split(' '))) {
      return true;
    } else if (in$(value, 'no false off bad 0'.split(' '))) {
      return false;
    } else {
      return void 8;
    }
  },
  'if': function(scope, list){
    var exp, when_yes, when_no, ret;
    log('if:', list);
    exp = list[0];
    when_yes = list[1];
    when_no = list[2];
    ret = void 8;
    if (read(scope, exp)) {
      return read(scope, when_yes);
    } else if (when_no != null) {
      return read(scope, when_no);
    }
  },
  smaller: function(scope, list){
    var stack, i$, len$, item, num;
    log('smaller:', list);
    stack = void 8;
    for (i$ = 0, len$ = list.length; i$ < len$; ++i$) {
      item = list[i$];
      num = read(scope, item);
      if (stack != null) {
        log('smaller:', num, stack);
        if (num <= stack) {
          return false;
        }
      }
      stack = num;
    }
    return true;
  },
  larger: function(scope, list){
    var stack, i$, len$, item, num;
    log('larger:', list);
    stack = void 8;
    for (i$ = 0, len$ = list.length; i$ < len$; ++i$) {
      item = list[i$];
      num = read(scope, item);
      if (stack != null) {
        if (num >= stack) {
          return false;
        }
      }
      stack = num;
    }
    return true;
  },
  read: function(scope, list){
    var value;
    log('read:', list);
    value = read(scope, list[0]);
    log('read value:', value);
    return read(scope, value);
  },
  select: function(scope, list){
    var obj, point;
    log('select:', list);
    obj = read(scope, list[0]);
    point = read(scope, list[1]);
    if (isNum(point)) {
      point -= 1;
    }
    return obj[point];
  },
  put: function(scope, list){
    var obj, point, value;
    log('put:', list);
    obj = read(scope, list[0]);
    point = read(scope, list[1]);
    if (isNum(point)) {
      point -= 1;
    }
    value = read(scope, list[2]);
    return obj[point] = value;
  },
  mess: function(scope, list){
    var ret;
    log('mess:', list);
    ret = macro(scope, list);
    log('mess result:', ret);
    return ret;
  },
  eval: function(scope, list){
    var value;
    log('eval:', list);
    value = read(scope, list[0]);
    return read(scope, read(scope, value[0]));
  },
  comment: function(){
    return '';
  }
};
exports.run = function(scope, list){
  log('\nrun global:', list);
  scope.__proto__ = global;
  scope[' clear']();
  list.forEach(function(item){
    return read(scope, item);
  });
  return scope;
};
function in$(x, arr){
  var i = -1, l = arr.length >>> 0;
  while (++i < l) if (x === arr[i] && i in arr) return true;
  return false;
}