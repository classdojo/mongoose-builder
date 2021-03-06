// Generated by CoffeeScript 1.6.2
/*
  This module creates exports a relation proxy class
  and also exports a handler that child_plugin can
  inject into a mongoose schema.
*/


/*
  class: RelationProxy

  Responsible for piecing together the optional arguments
  from a relational request.

  eg.
    
    options =
      query: {some mongoose compliant restriction query}
      permissions: <PermissionObject>
    
    teacher.classes (err, classes) ->

  By default only resources that the owner resource DIRECTLY owns
  will be returned.  See permission.coffee for information about
  how to configure a Permissions object to represent both owned
  and shared resources.

  NOTE (chris): To really get these chained calls to work we either
  need to modify the api with

    teacher.classes({some query}).with("students").with("awardRecords")....

    OR

    use harmony proxies to create GET traps on the chain.  Favoring harmony
    proxies in the longterm..but short term will probably stick with some chained
    method.
*/


(function() {
  var RelationProxy, handle,
    __slice = [].slice;

  RelationProxy = (function() {
    function RelationProxy(thisModel, options) {
      this._currModel = thisModel;
      this._currOptions = this.options;
      this._callStack = [];
    }

    RelationProxy.prototype.exec = function(callback) {
      var q;

      if (this._callStack.length !== 0) {

      } else {
        if (!utils.objectContains('own', this._currModel)) {
          return callback(new Error("Object " + this._currModel + " must inherit from type owner!"), null);
        } else {
          q = this.buildMongooseQuery(this._currModel, this._currOptions);
          return callback(null, q);
        }
      }
    };

    /*
      Decouple from current class variables @_curr*  in case
      we need to use this function in some sort of iteration.
    
      eg.
        for s in @_callStack
          @buildMongooseQuery(s.model, s.options)
    */


    RelationProxy.prototype.buildMongooseQuery = function(model, options) {
      var myBaseQuery, optional, q;

      optional = {};
      if (options != null) {
        optional = {};
      }
      myBaseQuery = model._ownQuery();
      q = _.extend(myBaseQuery, optional);
      return q;
    };

    return RelationProxy;

  })();

  /*
    Handle exposed to the actual mongoose model instance. Must inject with a reference
    to mongoose model instances.
  */


  handle = function(models, childInfo) {
    return function() {
      var args, fn, rP,
        _this = this;

      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (_.isFunction(args[0]) || _.isFunction(args[1])) {
        if (_.isFunction(args[0])) {
          fn = args[0];
          rP = new RelationProxy(this, null);
        } else {
          fn = args[1];
          rP = new RelationProxy(this, args[0]);
        }
        return rP.exec(function(err, query) {
          if (err != null) {
            return fn(err, null);
          } else {
            console.log("FULLY QUALIFIED", query);
            return models[childInfo.name].find(query, fn);
          }
        });
      } else {
        throw new Error("Can't use chained calls yet :)");
        rP = new RelationProxy(this, args[0]);
        return rP.exec();
      }
    };
  };

  exports.handle = handle;

}).call(this);
