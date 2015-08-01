{BufferedProcess, File, CompositeDisposable, Emitter} = require 'atom'
Q = require 'q'
path = require 'path'

Q.stopUnhandledRejectionTracking()

module.exports =
class BowerManager
  constructor: ->
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

    options = cwd: atom.project.getPaths()[0]
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
          {name: details.pkgMeta.name, version: details.pkgMeta.version}
        callback(null, packages)
      else
        error = new Error(errorMessage)
        error.stdout = stdout
        error.stderr = stderr
        callback(error)

    handleProcessErrors(bowerProcess, errorMessage, callback)

  getInstalled: ->
    Q.nbind(@loadInstalled, this)()

  createProcessError = (message, processError) ->
    error = new Error(message)
    error.stdout = ''
    error.stderr = processError.message
    error

  handleProcessErrors = (bowerProcess, message, callback) ->
    bowerProcess.onWillThrowError ({error, handle}) ->
      handle()
      callback(createProcessError(message, error))
