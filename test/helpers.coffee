http = require('http')
Client = require('request-json').JsonClient
americano = require 'americano'
path = require 'path'
clientDS = new Client 'http://localhost:9101'


helpers = {}
ref = if process.env.COVERAGE
    helpers.prefix = path.join __dirname, '../instrumented'
else if process.env.USE_JS
    helpers.prefix = path.join __dirname, '../build'
else
    helpers.prefix = path.join __dirname, '..'

# Bring models in context
File = require helpers.prefix + '/server/models/file'
Folder = require helpers.prefix + '/server/models/folder'


# init the compound application
# will create @app in context
# usage : before helpers.init port
_init = (ctx, port, done) ->
    params = name: 'files', port: port, root: helpers.prefix
    americano.start params, (app, server) =>
        app.server = server
        ctx.app = app
        done()

# This function remove everythin from the db
_cleanDb = helpers.cleanDb = (callback) ->
    Folder.destroyAll (err) ->
        console.log err
        return callback err if err
        File.destroyAll (err) ->
            return callback err

helpers.setup = (port) ->
    (done) ->
        @timeout 5000
        _init this, port, (err) =>
            return done err if err
            _cleanDb done

helpers.takeDown = (done) ->
    @app.server.close()
    _cleanDb done


module.exports = helpers