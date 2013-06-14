ModelInitializer = require("#{__dirname}/model")


exports.requirements = ["initializers.relational"]
exports.plugin = (Relational) ->
  console.log "RELATIONAL", Relational
  # console.log "RELATIONAL ! ", Relational._plugins._pluginL
  ModelInitializer.use "Relational", Relational
  ModelInitializer
