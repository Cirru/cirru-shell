
util = require 'util'
readline = require 'readline'

evaluator = require './evaluator'

completer = (line) ->
  matchLastWord = line.match(/[\w-:\/]+$/)
  return [evaluator.candidates, ''] unless matchLastWord?
  lastWord = matchLastWord[0]
  wordsBefore = line[...(-lastWord.length)]
  # console.log "(#{lastWord})"
  # console.log 'before:', wordsBefore
  hits = evaluator.candidates
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
    resultString = evaluator.call null, anwser
    console.log resultString
    repl()