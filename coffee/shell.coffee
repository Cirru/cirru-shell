
util = require 'util'
readline = require 'readline'

evaluator = require './evaluator'

completer = (line) ->
  if line[line.length - 1] is '('
    # console.log shell.line, shell.cursor
    if shell.line[shell.cursor] isnt ')'
      setTimeout ->
        shell._moveCursor -1
      , 0
      return [['()'], '(']
    else
      return []
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
    []

shell = readline.createInterface
  input: process.stdin
  output: process.stdout
  completer: completer

shell.setPrompt 'cirru> '
shell.prompt()

shell.on 'line', (anwser) ->
  try
    resultString = evaluator.call null, anwser
    util.print '=> '
    console.log resultString
  catch error
    console.log error
  console.log ''
  shell.prompt()