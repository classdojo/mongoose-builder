

# class MongooseChild

#   addChild: 

# module.exports = MongooseChild


###
  This "plugin" is a vanilla mongoose plugin
###
exports.plugin = (schema, options) ->
  childName = options.child.name
  childSchema = options.child.schema
  childModel = options.child.model

  console.log "Adding child method #{childName} to schema"
  schema.methods[childName] = (args...) ->
    console.log "getting child documents"
    # q = @_ownQuery()
    console.log "extracted own query- "
