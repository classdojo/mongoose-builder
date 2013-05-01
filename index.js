(function (exports) {

  var MongooseBuilder, MongooseRelational;

  //export utils to global namespace
  utils = require("./lib/utils");

  //let's also include a global collection -> schema mapper

  MongooseBuilder    = require("./lib/core/graph/builders/mongo");
  MongooseRelational = require("./lib/core/graph/builders/helpers/relational/mongo_relational");

  exports.Builder    = MongooseBuilder;
  exports.Relational = MongooseRelational;

})(exports);
