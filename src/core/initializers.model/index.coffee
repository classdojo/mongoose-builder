ModelInitializer = require("#{__dirname}/model")

exports.requirements = ["initializers.relational"]
exports.plugin = (Relational) ->
  ModelInitializer.use "Relational", Relational
  ModelInitializer
