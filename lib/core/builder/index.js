// Generated by CoffeeScript 1.6.2
(function() {
  exports.plugin = function() {
    /*
      class: MongooseBuilder
    
      Handles all the details of using a resource to
      build out the model dependency graph.
    */

    var ModelInitializer, MongoInitializer, MongooseBuilder;

    ModelInitializer = require("" + __dirname + "/../initializers.model/model");
    MongoInitializer = require("" + __dirname + "/../initializers.database").plugin();
    /*
      Class: MongooseBuilder
    
      Implements the builder interface with one helper method
    */

    MongooseBuilder = (function() {
      /*
        Method: constructor
      */
      function MongooseBuilder(nodeBuilder, nodeManager, dbSettings) {
        this._nodeManager = nodeManager;
        this._nodeBuilder = nodeBuilder;
        this._dbSettings = dbSettings;
        this._plugins = {};
      }

      MongooseBuilder.prototype.preBuild = function(callback) {
        var _this = this;

        this._modelInitializer = new ModelInitializer(this._nodeBuilder, this._nodeManager, this._plugins);
        this._mongoConn = new MongoInitializer(this._dbSettings);
        return this._modelInitializer.init(function(err) {
          return _this._modelInitializer.addSchemaPlugins(function(err) {
            return _this._mongoConn.connect(function(err) {
              return callback(err);
            });
          });
        });
      };

      /*
        Method: build
      
        Expects preBuild() was called prior to calling this method.
      */


      MongooseBuilder.prototype.build = function(callback) {
        var _this = this;

        return this._modelInitializer.createModels(this._mongoConn.get(), function(err) {
          return callback(err);
        });
      };

      MongooseBuilder.prototype.postBuild = function(callback) {
        return callback(null);
      };

      MongooseBuilder.prototype.registerPlugin = function(name, Plugin) {
        return this._plugins[name] = Plugin;
      };

      /*
        Method: getDrivers
      */


      MongooseBuilder.prototype.getDrivers = function() {
        return this._modelInitializer.models;
      };

      return MongooseBuilder;

    })();
    return MongooseBuilder;
  };

}).call(this);