RelationProxy = require("#{__dirname}/relation_proxy")


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

  childName   = options.child.name
  childSchema = options.child.schema
  childColl   = options.child.collection
  
  parentName  = options.parent.name
  parentColl  = options.parent.collection

  permissionSchema  = options.permission.schema

  #permission field
  newChildSchemaField = {}
  newChildSchemaField["_#{parentColl}"] = [permissionSchema]
  childSchema.add newChildSchemaField

  #let's add the child handler function

  # selector object
  schema.methods["#{childColl}_"] = RelationProxy.handle(models, options.child)


# handler = (r) ->
#   return (args...) ->
#       if typeof args[0] isnt 'function'
#         opts = args[0]
#         fn = args[1]
#       else
#         fn = args[0]
#       query = {}
#       if opts?
#         #handle options
#         query = r._generateQuery opts
#       me = @

#       _.merge @_own

# class Relational

#   constructor: (parent, child, models) ->
#     @_parent = parent
#     @_child = child
#     @_models = models

#   generateQuery: (opts) ->
#     return {}


# teacher.classes((err) ->)

# permission = new PermissionObject()
# permission.level()
# teacher.classes( {some Restictions}, PermissionsObject, (err, classes) -> )


# teacher.classes({some Restrictions}, )

# teachers.classes (err, classes) ->

# permission = new Permissions()
# permission.shared = true

# permission.level(READ)
# permission.level(ALL)


# teacher.classes({some Res})
