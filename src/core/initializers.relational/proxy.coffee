###
  This module creates exports a relation proxy class
  and also exports a handler that child_plugin can
  inject into a mongoose schema.
###


###
  class: RelationProxy

  Responsible for piecing together the optional arguments
  from a relational request.

  eg.
    
    options =
      query: {some mongoose compliant restriction query}
      permissions: <PermissionObject>
    
    teacher.classes (err, classes) ->

  By default only resources that the owner resource DIRECTLY owns
  will be returned.  See permission.coffee for information about
  how to configure a Permissions object to represent both owned
  and shared resources.

  NOTE (chris): To really get these chained calls to work we either
  need to modify the api with

    teacher.classes({some query}).with("students").with("awardRecords")....

    OR

    use harmony proxies to create GET traps on the chain.  Favoring harmony
    proxies in the longterm..but short term will probably stick with some chained
    method.
###


class RelationProxy

  constructor: (thisModel, options) ->
    @_currModel = thisModel
    @_currOptions = @options
    @_callStack = []

  exec: (callback) ->
    # if not callback?
    #   #this is a chained call
    #   q = @_buildMongooseQuery(@_currModel, @_currOptions)
    #   stackEntry =
    #     model: @_currModel
    #     options: @_currOptions
    #     cachedQuery: q
    #   # callChain should really be a list
    #   # of mongoose query objects
    #   @_callChain.push  stackEntry
    #   return @
    # else
    if @_callStack.length isnt 0
      #execute call stack
    else
      #this is a single call
      if not utils.objectContains('own', @_currModel)
        callback new Error("Object #{@_currModel} must inherit from type owner!"), null
      else
        q = @buildMongooseQuery(@_currModel, @_currOptions)
        callback null, q


  ###
    Decouple from current class variables @_curr*  in case
    we need to use this function in some sort of iteration.

    eg.
      for s in @_callStack
        @buildMongooseQuery(s.model, s.options)
  ###
  buildMongooseQuery: (model, options) ->
    optional = {}
    if options?
      #handle options brah
      optional = {}
    myBaseQuery = model._ownQuery()
    q = _.extend(myBaseQuery, optional)  #optional fields can override base...
    #also provide an index hint?
    return q


###
  Handle exposed to the actual mongoose model instance. Must inject with a reference
  to mongoose model instances.
###
handle = (models, childInfo) ->
  return (args...) ->
    if _.isFunction(args[0]) || _.isFunction(args[1])
      #create relation proxy and execute now
      if _.isFunction(args[0])
        fn = args[0]
        rP = new RelationProxy(@, null)
      else
        fn = args[1]
        rP = new RelationProxy(@, args[0])
      rP.exec (err, query) =>
        if err?
          fn err, null
        else
          console.log "FULLY QUALIFIED", query
          models[childInfo.name].find(query, fn)
      # return @find(qualifiedQuery, args[0])
    else
      #this is a chained callback
      throw new Error("Can't use chained calls yet :)")
      rP = new RelationProxy(@, args[0])
      return rP.exec()

exports.handle = handle
