exports.plugin = () ->

  class Permission

    ###
      Permission Levels
    ###
    @R      = 0
    @RW     = 1
    @RWD    = 2
    @SUPER  = 3

    ###
      Method: constructor

      @param - ownerResource <Object> - A mongoose
               model instance that implements the
               owner interface.
      @param - pLevel - A valid permission level.

                  Permission.R
                  Permission.RW
                  Permission.RWD
                  Permission.SUPER

    ###
    constructor: (ownerResource, pLevel, featureFlags) ->
      @__owner = ownerResource
      @__pLevel = pLevel
      @__featureFlags = featureFlags

    ###
      Method: serialize

      Creates a permission object consistent
      with the applications permission schema.

      TODO(chris): allow client to specify what
      serialize returns.
    ###
    serialize: () ->
      p =
        _id: @__owner.id
        l: @__pLevel
        f: @__featureFlags
      return p

    ###
      Equality methods
    ###

    gt: (pObj) ->
      @__pLevel > pObj.l

    gte: (pObj) ->
      @__pLevel >= pObj.l

    lt: (pObj) ->
      @__pLevel < pObj.l

    lte: (pObj) ->
      @__pLevel <= pObj.l

    @::__defineGetter__ 'level', () ->
      @__pLevel

  Permission
