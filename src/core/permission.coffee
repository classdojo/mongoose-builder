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
  constructor: (ownerResource, pLevel) ->
    @_owner = ownerResource
    @_pLevel = pLevel

  ###
    Method: serialize

    Creates a permission object consistent
    with the applications permission schema.

    TODO(chris): allow client to specify what
    serialize returns.
  ###
  serialize: () ->
    p =
      _id: @_owner.id
      l: @_pLevel
    return p

  ###
    Equality methods
  ###

  gt: (pObj) ->
    @_pLevel > pObj.l

  gte: (pObj) ->
    @_pLevel >= pObj.l

  lt: (pObj) ->
    @_pLevel < pObj.l

  lte: (pObj) ->
    @_pLevel <= pObj.l

  @::__defineGetter__ 'level', () ->
    @_pLevel

module.exports = Permission
