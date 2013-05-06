###
  class: MongooseBuilder

  Handles all the details of using a resource to
  build out the model dependency graph.
###

# BaseBuilder = require("./base")
ModelInitializer = require("./helpers/model")
MongoInitializer = require("./helpers/mongo")

MongooseRelational  = require("./helpers/relational/mongoose_relational")

###
  Class: MongooseBuilder

  Implements the builder interface with one helper method
###

class MongooseBuilder


  ###
    Method: constructor
  ###
  #Need relation, schema, and db settings.  Objects not
  # filepaths
  constructor: (relations, rawSchemas, dbSettings) ->
    # @_base = new BaseBuilder relation, @
    @_relations  = relations
    @_rawSchemas = rawSchemas
    @_dbSettings = dbSettings
    @_plugins    = {}

  preBuild: (callback) ->

    #Mongo initializer doesn't need dbSettings until initializing models
    @_modelInitializer = new ModelInitializer @_relations, @_rawSchemas, @_plugins
    @_mongoConn = new MongoInitializer @_dbSettings
    @_modelInitializer.prepSchemas (err) =>
      @_mongoConn.connect (err) =>
        callback err
    #parses the config
    #gets the schema definitions
    #initializes schemas

  ###
    Method: build

    Expects preBuild() was called prior to calling this method.
  ###
  build: (callback) ->
    @_modelInitializer.addSchemaPlugins (err) =>
      #need to do relational operations here.
      if @_relationalCallback?
        #pass control there
        #let's initialize a Relational instance and pass to callbakc
        relationBuilder = new MongooseRelational(@_modelInitializer.schemas, @_modelInitializer.models)
        @_relationalCallback relationBuilder, (err) =>

        # @_relationalCallback @_relations, @_modelInitializer.schemas, (err) =>
          @_modelInitializer.createModels @_mongoConn.get(), (err) =>
            console.log "Created models"
            callback err
      else
        # relational = new Relational @_relations, 
        @_modelInitializer.createModels @_mongoConn.get(), (err) =>
          console.log "Created models"
          callback err

  postBuild: (callback) ->
    callback null

  ###
    Method: onRelational
    
    Sets an optional callback with which to pass back control to the client in order
    to implement some relational operations among the various data initialization stages.

    Since this builder is mongo specific, then it should know what to pass back to the callback
    in order for the MongoRelational class to perform correctly.
  ###
  onRelational: (callback) ->
    @_relationalCallback = callback

  registerPlugin: (name, Plugin) ->
    @_plugins[name] = Plugin

  ###
    Method: getDrivers


  ###
  getDrivers: () ->
    @_modelInitializer.models

module.exports = MongooseBuilder
