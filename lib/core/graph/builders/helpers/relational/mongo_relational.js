// Generated by CoffeeScript 1.4.0

/*
  Responsible for defining all the relational operations between
  schemas as defined by a valid relation.json config file
*/


(function() {
  var MongoRelational, MongooseChild, NodeManager,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  NodeManager = require("" + __dirname + "/node_manager");

  MongooseChild = require("" + __dirname + "/mongoose_child");

  MongoRelational = (function() {
    /*
        Method: constructor
        
        Relations in the realtions config file. Delegates build operations to build
        specific _relation object
    */

    function MongoRelational(schemas) {
      this.addRelationship = __bind(this.addRelationship, this);
      this._schemas = schemas;
      this._nodeManager = new NodeManager();
    }

    /*
        Method: addRelationship
    
        Creates a relationship between node1 and node2 of type, type. Valid
        types are
          "parent_child"
          "orphan"
    
        Orphan types will add the model to the orphaned collections
    */


    MongoRelational.prototype.addRelationship = function(schema1Name, schema2Name, type, callback) {
      var options, s1, s2;
      if (type === "parent_child") {
        s1 = this._schemas['Teacher'];
        s2 = this._schemas['Classes'];
        options = {
          child: {
            name: schema2Name,
            schema: s2
          }
        };
        s1.plugin(MongooseChild.plugin, options);
        return this._nodeManager.addChild(schema1Name, schema2Name);
      } else if (type === "orphan") {
        return this._nodeManager.addOrphan(node1);
      } else {
        return console.log("Ignoring relationship type " + type);
      }
    };

    return MongoRelational;

  })();

  module.exports = MongoRelational;

}).call(this);