
require 'shelljs/make'

target.build = ->
  exec 'coffee -o src/ -bc coffee/'