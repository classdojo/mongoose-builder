plugin = require("plugin")

loader = plugin.
require("core")

loader.load (err) ->
  if err?
    console.error err.stack

modules = {}

