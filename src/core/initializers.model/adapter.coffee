###
  A small mongoose adapter that transforms schemas from class-like coffeescript classes
  into the more idosyncratic mongoose plugin interface
###


exports.adapt = (schema, options, plugin) ->
  #expands a plugins methods and adds to mongoose
  #schema object
  _plugin = (skema, options) ->
    #get configuration
    configuration = options.nodeManager.find(options.thisCollectionName).configuration
    for pluginMethodName, pluginMethodDefinition of plugin::
      if pluginMethodName is 'constructor'
        continue
      #ADD ALL THE METHODS. Give priority to schema instance method definitions.
      skema.methods[pluginMethodName] = configuration.methods.instance[pluginMethodName] || pluginMethodDefinition
    #add any other instance methods that don't override default plugin methods
    for instanceMethodName, instanceMethodDefinition of configuration.methods.instance
      if not skema.methods[instanceMethodName]?
        skema.methods[instanceMethodName] = instanceMethodDefinition


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

    ##User defined firtuals
    if configuration.virtuals?
      for m, fn of configuration.virtuals.get
        skema.virtual("#{m}").get fn

      for m, fn of configuration.virtuals.set
        skema.virtual("#{m}").set fn

  schema.plugin _plugin, options
