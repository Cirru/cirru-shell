
util = require 'util'
readline = require 'readline'

candidates = ['acd', 'sdfsdf', 'akne', 'wave', 'make']

completer = (line) ->
  matchLastWord = line.match(/[\w-:\/]+$/)
  return [candidates, ''] unless matchLastWord?
  lastWord = matchLastWord[0]
  wordsBefore = line[...(-lastWord.length)]
  # console.log "(#{lastWord})"
  # console.log 'before:', wordsBefore
  hits = candidates
  .filter (word) ->
    (word.indexOf lastWord) is 0
  if hits.length > 0
    # console.log [hits, line]
    [hits, lastWord]
  else
    [[], null]

shell = readline.createInterface
  input: process.stdin
  output: process.stdout
  completer: completer

do repl = ->
  shell.question 'cirru> ', (anwser) ->
    console.log anwser
    repl()