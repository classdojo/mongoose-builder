RelationProxy = require("#{__dirname}/proxy")

###
  This "plugin" is a vanilla mongoose plugin

  Does two things.

  1. Adds the permission control field for the parent object into
  the child's schema.

  eg.  if teachers --(parentOf)-> classes

  then the classes schema will get a field called _teachers
###
exports.plugin = (schema, options) ->
  models = options.mongoose.models

  childSchema = options.child.schema
  childColl   = options.child.collectionName
  
  parentColl  = options.parent.collectionName

  permissionSchema  = options.permission.schema

  #permission field
  newChildSchemaField = {}
  newChildSchemaField["_#{parentColl}"] = [permissionSchema]
  childSchema.add newChildSchemaField

  #let's add the child handler function

  # selector object
  schema.methods["#{childColl}_"] = RelationProxy.handle(models, options.child)
