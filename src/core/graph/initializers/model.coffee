mongoose = require("mongoose")
Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId

_MongooseAdapter    = require("./helpers/_adapter")
MongooseRelational  = require("./relational/mongoose_relational")

###
Specific plugins
###

class ModelInitializer


  ###
    Method: constructor
  ###

  constructor: (nodeBuilder, plugins) ->
    @_nodeBuilder = nodeBuilder
    @_plugins     = plugins
    @_models      = {}
    @_rawSchemas  = {}
    @_schemaTypes = {}

    #used for adding the child plugin hooks
    #into the schemas
    @_childRelationships = {}

  ###
    Method: prepSchemas

    Initializes mongoose schemas with mongoose specific
    schema format.
  ###

  init: (callback) ->
    @_nodeBuilder.each (node) =>
      @_rawSchemas[node.name] = node.schema
      @_schemaTypes[utils.pluralize(node.name)] = node.type

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
    @_nodeBuilder.each (n) =>
      collectionName = utils.pluralize(n.name)
      options =
        thisSchemaName: n.name
        thisCollectionName: utils.pluralize(n.name)
        models: @_models
        short_name: n.short_name
      plugin = @_plugins[n.type]
      if plugin?
        console.log "Enriching schema #{n.name} - #{n.type}"
        schema = @_schemas[n.name]
        _MongooseAdapter.adapt schema, options, plugin
      else
        console.error "Schema #{n.name} of type #{n.type} has no associated plugin."
    @_addRelationshipHooks (err) ->
      callback err

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
  @::__defineGetter__ 'models', () ->
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
    @_nodeBuilder.each (n) =>
      s = new Schema n.schema.fields, {collection: utils.pluralize(n.name)} 
      @_addIndices s, n.schema
      schemas[n.name] = s
    for schemaName, schema of schemas
      @_addEmbeddedFields schemaName, schema, schemas
    return schemas


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

    Adds embedded fields to schema.
  ###
  _addEmbeddedFields: (schemaName, schemaToAdd, allSchemas) ->
    n = @_nodeBuilder.find(schemaName)
    if not n?
      console.error "Cannot find node for schema #{schemaName}"
    else
      rawSchema = n.schema
      if rawSchema.embed?
        for field, embeddedSchema of rawSchema.embed
          obj = {}
          if _.isArray embeddedSchema
            sVal = [allSchemas[embeddedSchema[0]]]
          else
            sVal = allSchemas[embeddedSchema]
          obj[field] = sVal
          schemaToAdd.add obj

  _addRelationshipHooks: (callback) ->
    mongooseRelational = new MongooseRelational(@_schemas, @_models)
    permissionNode = @_nodeBuilder.find('Permission')
    if not permissionNode?
      callback new Error("Permission node seems to be missing. Please ensure that you've defined a Permission schema")
    else
      @_nodeBuilder.each (n) =>
        if n.children?
          #create array of both many and one relationships
          children = (n.children.many || []).concat(n.children.one || [])
          if _.isEmpty(children)
            opts =
              orphan: n.name
            mongooseRelational.addRelationship "orphan", opts
          else
            for childName in children
              childNode = @_nodeBuilder.find(childName)
              opts =
                parent:
                  name: n.name
                child:
                  name: childNode.name
              mongooseRelational.addRelationship "parent_child", opts
      callback null

module.exports = ModelInitializer
