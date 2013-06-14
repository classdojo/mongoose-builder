(function (exports) {

  var MongooseBuilder, MongooseRelational, MongoosePermission;

  //export utils to global namespace.  Let's namespace these global
  //functions too.
  utils = require("./lib/utils");
  _     = require("underscore");

  exports.Builder    = require("./lib/core/builder").plugin();
  exports.Relational = require("./lib/core/initializers.relational").plugin(); //modules["MongooseRelational"];
  exports.Permission = require("./lib/core/permission").plugin();//modules["MongoosePermission"];
  // //let's also include a global collection -> schema mapper

  //register ObjectID globally...
  global.ObjectID = require("mongoose").Schema.Types.ObjectId

})(exports);
