(function (exports) {

  var MongooseBuilder, MongooseRelational, MongoosePermission;

  //export utils to global namespace.  Let's namespace these global
  //functions too.
  utils = require("./lib/utils");
  _     = require("underscore");

  modules = require("./lib/bootstrap");

  exports.Builder = modules["MongooseBuilder"];
  exports.Relational = modules["MongooseRelational"];
  exports.Permission = modules["MongoosePermission"];
  // //let's also include a global collection -> schema mapper

  // MongooseBuilder    = require("./lib/core/builder");
  // MongooseRelational = require("./lib/core/initializers.relational");
  // MongoosePermission = require("./lib/core/permission");

  // exports.Builder    = MongooseBuilder;
  // exports.Relational = MongooseRelational;
  // exports.Permission = MongoosePermission;

  //register ObjectID globally...
  global.ObjectID = require("mongoose").Schema.Types.ObjectId

})(exports);
