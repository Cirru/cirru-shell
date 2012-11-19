var cirruParser, run, fs, toList;
cirruParser = require('cirru-parser');
run = require('./run').run;
fs = require('fs');
toList = function(list){
  return list.map(function(item){
    if (Array.isArray(item)) {
      return toList(item);
    } else {
      return item.line;
    }
  });
};
exports.run = function(){
  var fileName, code, tree, scope;
  fileName = process.argv[2];
  code = fs.readFileSync(fileName, 'utf8');
  tree = toList(cirruParser.parser(code));
  scope = {};
  return run(scope, tree);
};