class Permission

  R     = 0   #GET
  RW    = 1   #GET, POST
  RWD   = 2
  SUPER = 3



  constructor: (pLevel) ->
    @_pLevel = pLevel

  @::__defineGetter__ 'level', () ->
    @_pLevel

module.exports = Permission