###
  Responsible for defining all the relational operations between
  schemas as defined by a valid relation.json config file
###

#relational should load component class and construct through the abstract interface

#child mongoose plugin
MongooseChild = require("#{__dirname}/child_plugin")

class MongoRelational

  ###
    Method: constructor
    
    Delegates build operations to build
    specific _relation object.

    Schemas collection used to inject specific
    instance methods into each model.

    Also pass in a reference to the models object which
    at this point is uninitialized. will soon be populated
    with model objects that communicate directly to the mongo
    database.

    child_plugin requires a reference to models in order to carry
    out Relational Proxy operations.
  ###
  constructor: (schemas, models) ->
    @_schemas = schemas
    @_models = models
    #construct empty NodeManager

  ###
    Method: addRelationship  (Synchronous)

    Creates a relationship between node1 and node2 of type, type. Valid
    types are
      "parent_child"
      "orphan"

    Orphan types will add the model to the orphaned collections.


  ###
  addRelationship: (type, sNames) =>
    if type is "parent_child"
      parentName = sNames.parent
      childName  = sNames.child
      parent    = @_schemas[parentName]
      child = @_schemas[childName]

      options =
        mongoose:
          models: @_models
        child:
          name: childName
          schema: child
          collection: utils.pluralize(childName)
        parent:
          name: parentName
          collection: utils.pluralize(parentName)
        permission:
          schema: @_schemas['Permission']

      parent.plugin MongooseChild.plugin, options
      #add to node manager
    else if type is "orphan"
      orphan = sNames.orphan
    else
      console.log "Invalid type #{type}"

    # if type is "parent_child"
    #   s1 = @_schemas['Teacher']
    #   s2 = @_schemas['Classes']
    #   options =
    #     child:
    #       name: schema2Name
    #       schema: s2
    #   s1.plugin MongooseChild.plugin, options
    #   #enrich node1 through child plugin
    #   #add parent permission fields to schema with appropriate indices
    #   @_nodeManager.addChild(schema1Name, schema2Name)  #add to nodeManager
    # else if type is "orphan"
    #   @_nodeManager.addOrphan(node1)
    # else
    #   console.log "Ignoring relationship type #{type}"


module.exports = MongoRelational
