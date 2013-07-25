###
  A small mongoose adapter that transforms schemas from class-like coffeescript classes
  into the more idosyncratic mongoose plugin interface
###
_ = require("underscore")


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

      Every model gets a _type_, _models_, and _configuration_ virtual.
      These methods use _ to prevent naming collisions with mongoose.

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

    skema.virtual('_configuration_').get () ->
      configuration
    skema.statics._configuration_ = () ->
      configuration

    ##User defined virtuals
    if configuration.virtuals?
      for m, fn of configuration.virtuals.get
        skema.virtual("#{m}").get fn

      for m, fn of configuration.virtuals.set
        skema.virtual("#{m}").set fn

    #Add a jsonify function
    skema.methods.jsonify = () ->
      console.log 
      driverConf = @_configuration_.driver
      #substitute map fields
      o = {}
      for dbField of driverConf.schema.fields
        if driverConf.schema.clientMappings?
          if (newName = driverConf.schema.clientMappings["#{dbField}"])?
            o["#{newName}"] = @["#{dbField}"]
          else
            o["#{dbField}"] = @["#{dbField}"]
        else
          o["#{dbField}"] = @["#{dbField}"]

      #add virtual fields. These functions should all be synchronous
      if driverConf.schema.virtualFields?
        for virtualName, virtualFn of driverConf.schema.virtualFields
          o["#{virtualName}"] = virtualFn()

      #add any attached fields. These fields are given preference.
      if @_configuration_.attach?
        for attachedField of @_configuration_.attach
          if @_doc["#{attachedField}"]?
            o["#{attachedField}"] = @_doc["#{attachedField}"]

      #always include the _id field
      o._id = @_id
      return o

    skema.methods.attach = (name, clbk) ->
      if not @_configuration_.attach? or not @_configuration_.attach["#{name}"]?
        clbk(new Error("No attachment with name #{name}"), null)
      else
        @_configuration_.attach["#{name}"] @, (err, val) =>
          if err?
            clbk err, null
          else
            @._doc["#{name}"] = val
            clbk null, @

    ###
    unmaps a json field using schema.clientMappings, if they exist.
    function is synchronous.  Since this method is static, we must
    invoke _configuration_ to get it's value.
    ###
    skema.statics.unmap = (obj) ->
      mappings = @_configuration_().driver.schema.clientMappings
      if not mappings?
        return obj
      inverted = @_configuration_().__invertedFieldMap =
          @_configuration_().__invertedFieldMap || _.invert(mappings)
      o = {}
      for k,v of obj
        if inverted[k]?
          o[inverted[k]] = v
        else
          o[k] = v
      return o

  schema.plugin _plugin, options
