// Generated by CoffeeScript 1.4.0
(function() {
  var NodeManager,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  NodeManager = (function() {

    function NodeManager() {
      this.orphan = __bind(this.orphan, this);

      this.addChild = __bind(this.addChild, this);

    }

    NodeManager.prototype.addChild = function(parent, child) {};

    NodeManager.prototype.orphan = function() {};

    return NodeManager;

  })();

  module.exports = NodeManager;

}).call(this);