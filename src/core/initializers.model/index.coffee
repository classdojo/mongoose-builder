ModelInitializer = require("#{__dirname}/model")


exports.requirements = ["initializers.relational"]
exports.plugin = () ->
  ModelInitializer
