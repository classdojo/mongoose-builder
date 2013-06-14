exports.plugin () ->
  ###
  This is class abstracts away mongoose connections
  ###
  mongoose = require("mongoose")
  _        = require("underscore")

  class Connections
    ###
    databaseSettings: {Object} -> This should be a hash
    with the following structure:

    databaseTag1:
      name: "name of the database in the mongo cluster"
      host: ["primary host", "optional replica 1", "optional replica 2"]
      port: 1000 #port number
      user: "dbUser"
      pass: "dbPass"
      options:
        mongoNativeOption1: Value1
        moreDocumentation: http://docs.mongodb.org/manual/reference/connection-string/
    databaseTag2:
      ......
    ###
    constructor: (databaseSettings) ->
      @_settings = databaseSettings
      @_connections = null
      @initialized = false

    ###
      Method: connect
    ###
    connect: (callback) =>
      @_connections = {}
      for database, setting of @_settings.databases
        connString =
            @_constructConnectionString database, setting
        @_connections[database] =
            mongoose.createConnection connString
      @initialized = true
      callback null

    get: () =>
      return @_connections

    _constructConnectionString: (database, settings) =>
      connStrings = []
      if settings.user? and settings.pass?
        authString = "#{settings.user}:#{settings.pass}@"
      else
        authString = ""
      if not _.isArray(settings.host)
        throw new Error("Host must be an array of strings")
      #construct options string
      optionsStr = ""
      if settings.options?
        for opt, val of settings.options
          optionsStr += "#{opt}=#{val}&"
        optionsStr = optionsStr.replace(/&$/, "")
      for host in settings.host
        s = "#{authString}#{host}:#{settings.port}/#{settings.name}"
        if optionsStr.length > 0
          s += "?#{optionsStr}"  #add connection options here!
        connStrings.push(s)
      return connStrings.join(",")

  module.exports = Connections
