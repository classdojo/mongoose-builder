exports.plugin = () ->
  ###
    class: MongooseBuilder

    Handles all the details of using a resource to
    build out the model dependency graph.
  ###

  # BaseBuilder = require("./base")
  ModelInitializer = require("#{__dirname}/../initializers/model")
  MongoInitializer = require("#{__dirname}/../initializers/mongo")

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
    constructor: (nodeBuilder, nodeManager, dbSettings) ->
      @_nodeManager = nodeManager
      @_nodeBuilder = nodeBuilder
      @_dbSettings  = dbSettings
      @_plugins     = {}

    preBuild: (callback) ->

      #Mongo initializer doesn't need dbSettings until initializing models
      @_modelInitializer = new ModelInitializer @_nodeBuilder, @_nodeManager, @_plugins
      @_mongoConn = new MongoInitializer @_dbSettings
      @_modelInitializer.init (err) =>
        @_modelInitializer.addSchemaPlugins (err) =>
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
      @_modelInitializer.createModels @_mongoConn.get(), (err) =>
        callback err

    postBuild: (callback) ->
      callback null

    registerPlugin: (name, Plugin) ->
      @_plugins[name] = Plugin

    ###
      Method: getDrivers


    ###
    getDrivers: () ->
      @_modelInitializer.models

  MongooseBuilder
