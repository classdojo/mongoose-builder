(function (exports) {

  var MongooseBuilder, MongooseRelational, MongoosePermission;

  //export utils to global namespace.  Let's namespace these global
  //functions too.
  utils = require("./lib/utils");
  _     = require("underscore");

  //let's also include a global collection -> schema mapper

  MongooseBuilder    = require("./lib/core/graph/builders/mongo");
  MongooseRelational = require("./lib/core/graph/initializers/relational/mongoose_relational");
  MongoosePermission = require("./lib/core/permission");

  exports.Builder    = MongooseBuilder;
  exports.Relational = MongooseRelational;
  exports.Permission = MongoosePermission;

})(exports);
