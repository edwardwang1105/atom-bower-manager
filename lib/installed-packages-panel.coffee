{$$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class InstalledPackagesPanel extends View
  @content: ->
    @div =>
      @text "this is installed packages panel"

  initialize: (@bowerManager) ->
    @loadPackages()

  loadPackages: ->
    @bowerManager.getInstalled()
      .then (packages) =>
        console.log(packages)
