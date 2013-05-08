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
      #ADD ALL THE METHODS
      skema.methods[pluginMethodName] = pluginMethodDefinition

    #Also give each schema their type. This method definition also out of
    #place here. Let's find a better place to put it.
    skema.methods.type = () ->
      return options.thisCollectionName

  schema.plugin _plugin, options
