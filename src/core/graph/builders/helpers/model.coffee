mongoose = require("mongoose")
Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId
_MongooseAdapter = require("./_adapter")

###
Specific plugins
###

class ModelInitializer


  ###
    Method: constructor
  ###

  constructor: (relations, rawSchemas, plugins) ->
    @_relations = relations
    @_rawSchemas = rawSchemas
    @_plugins = plugins
    @_models = {}

  ###
    Method: prepSchemas

    Initializes mongoose schemas with mongoose specific
    schema format.
  ###

  prepSchemas: (callback) ->
    @_expandTypedPaths()
    @_schemas = @_initSchemas()
    callback null  #signal no error for now


  ###
    Method: addSchemaPlugins

    Determines each resource type and enriches
    it with the appropriate plugin.
  ###

  addSchemaPlugins: (callback) ->

    #let's loop through @_relations instead of
    #@_schemas
    #let's loop through @_schemas not relations

    for schemaName, schema of @_schemas
      options =
        models: @_models
        schemas: @_schemas
        thisSchema: schemaName
      collectionName = utils.pluralize(schemaName)
      relationConfig = @_relations[collectionName]
      if not relationConfig?
        console.log "No relation entry for schema #{schemaName}"
        console.log "Skipping..."
        continue
      # console.log "PP", @_plugins
      # console.log relationConfig
      plugin = @_plugins[relationConfig.type]
      if plugin?
        console.log "Enriching schema #{schemaName}"
        _MongooseAdapter.adapt schema, options, plugin
      else
        console.log "No plugin registered for #{relationConfig.type}"
    callback null

  ###
    Method: createModels

    Creates mongoose models from a set of passed in
    connection objects.  Connections are a hash with
    keys specifying the database type. For now there
    should only really be

      awardrecords:
        <conn object>
      default:
        <conn object>

  ###

  createModels: (connections, callback) ->
    for modelName, Schema of @_schemas
      if modelName is "AwardRecord"
        db = connections['awardrecords']
      else
        db = connections['default']
      @_models[modelName] = db.model modelName, Schema
    callback null

  ###
    Method: get

    Returns model instances
  ###
  get: () ->
    @_models

  @::__defineGetter__ 'schemas', () ->
    @_schemas


  ###
    private methods
  ###

  ###
    Private Method: _expandTypedPaths

    Expands schema fields from embedded objects
      field1: {
        field2: "val"
      }
    into dot notation

    field1.field2 = "val"
  ###
  _expandTypedPaths: (rawSchemas) ->

    _buildPath = (field, fieldVal, typedSchema) =>
      if _.isString fieldVal
        typedSchema[field] = fieldVal
      else
        for nestedKey, nestedField of fieldVal
          _buildPath "#{field}.#{nestedKey}", nestedField, typedSchema

    for schemaName, schemaDefn of rawSchemas
      typedSchema = schemaDefn.typed
      #for each typed field
      for field, fieldVal of typedSchema
        _buildPath field, fieldVal, typedSchema


  ###
    Private Method: _initSchemas

    Initializes mongoose schema objects adding
    indices and embedded documents.

    eg.
      Schema =
        typed:
          "field1": "String"
        indices:
          [{"field1": 1}]
        embed:
          "field2": ["SomeOtherSchema"]

    field1 is indexed and field2 is added as embedding
    SomeOtherSchema

  ###

  _initSchemas: () ->
    schemas = {}
    #create schemas
    for name, d of @_rawSchemas
      s = new Schema d.fields, {collection: utils.pluralize(name.toLowerCase())}
      #add indices
      @_addIndices s, d
      schemas[name] = s
    #add embedded fields
    for schemaName, schema of schemas
      @_addEmbeddedFields schemaName, schema, schemas
    schemas


  ###
    Private Method: _addIndices

    Adds indices to a schema. Called by _initSchemas
  ###

  _addIndices: (schema, rawSchema) ->
    if rawSchema.indices?
      for index in rawSchema.indices
        schema.index.apply(schema, index)

  ###
    Private Method: _addEmbeddedFields

    Adds embedded fields to schema. Callbed by _addEmbeddedFields
  ###
  _addEmbeddedFields: (schemaName, schemaToAdd, allSchemas) ->
    rawSchema = @_rawSchemas[schemaName]
    if rawSchema.embed?
      for field, embeddedSchema of rawSchema.embed
        obj = {}
        if _.isArray embeddedSchema
          sVal = [allSchemas[embeddedSchema[0]]]
        else
          sVal = allSchemas[embeddedSchema]
        obj[field] = sVal
        schemaToAdd.add obj

  _lowercasePlural: (name) ->
    name = name.toLowerCase() #fake implementation
    name = name + "s"
    return name

module.exports = ModelInitializer
