###
  A small mongoose adapter that transforms schemas from class-like coffeescript classes
  into the more idosyncratic mongoose plugin interface
###


exports.adapt = (schema, options, plugin) ->

  #expands a plugins methods and adds to mongoose
  #schema object
  _plugin = (skema, options) ->
    # console.log "A Plugin", plugin::
    for pluginMethodName, pluginMethodDefinition of plugin::
      if pluginMethodName is 'constructor'
        continue
      skema.methods[pluginMethodName] = pluginMethodDefinition

  schema.plugin _plugin, options
