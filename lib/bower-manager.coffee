{BufferedProcess, File, CompositeDisposable, Emitter} = require 'atom'
Q = require 'q'
path = require 'path'
request = require 'request'

Q.stopUnhandledRejectionTracking()

module.exports =
class BowerManager
  constructor: ->
    process.env.BOWER_HOME = atom.project.getPaths()[0]
    @packagePromises = []
    @availablePackageCache = null
    @emitter = new Emitter

  runCommand: (args, callback) ->
    command = 'bower'
    outputLines = []
    stdout = (lines) -> outputLines.push(lines)
    errorLines = []
    stderr = (lines) -> errorLines.push(lines)
    exit = (code) ->
      callback(code, outputLines.join('\n'), errorLines.join('\n'))

    options = cwd: process.env.BOWER_HOME
    new BufferedProcess({command, args, options, stdout, stderr, exit})

  loadInstalled: (callback) ->
    args = ['list', '--offline', '--json']
    errorMessage = 'Listing local packages failed.'
    bowerProcess = @runCommand args, (code, stdout, stderr) =>
      if code is 0
        try
          bowerListInfo = JSON.parse(stdout)
        catch parseError
          error = createJsonParseError(errorMessage, parseError, stdout)
          return callback(error)
        # @cacheAvailablePackageNames(packages)
        packages = for name, details of bowerListInfo.dependencies
          details.pkgMeta
        callback(null, packages)
      else
        error = new Error(errorMessage)
        error.stdout = stdout
        error.stderr = stderr
        callback(error)

    handleProcessErrors(bowerProcess, errorMessage, callback)

  getInstalled: ->
    Q.nbind(@loadInstalled, this)()

  getRegistered: ->
    # registeryUrl = 'https://bower-component-list.herokuapp.com/'
    # Q.nfcall request, registeryUrl
    deferred = Q.defer();

    registeryUrl = 'https://bower-component-list.herokuapp.com/'
    request.get registeryUrl, {json: true}, (error, response, body) ->
      if !error and response.statusCode is 200
        deferred.resolve body
      else
        deferred.reject new Error(error)

    deferred.promise

  createProcessError = (message, processError) ->
    error = new Error(message)
    error.stdout = ''
    error.stderr = processError.message
    error

  handleProcessErrors = (bowerProcess, message, callback) ->
    bowerProcess.onWillThrowError ({error, handle}) ->
      handle()
      callback(createProcessError(message, error))
