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



    ###
      TODO(chris): Figure out a way to set these virtuals
      in a more intuitive place.  Perhaps take in a virtual

      Every model gets a _type_ and _models_ virtual.
      These methods use _ to prevent naming collisions.

      _type_ is the collection name in mongo

      _models_ references initialized drivers and nodeManager
    ###
    skema.virtual('_type_').get () ->
      return options.thisCollectionName

    skema.statics._type_ = () ->
      return options.thisCollectionName
    if options.short_name?
      skema.virtual('_short_name_').get () ->
        return options.short_name

    skema.virtual('_models_').get () ->
      o =
        drivers: options.models
        nodeManager: options.nodeManager
      return o

  schema.plugin _plugin, options
