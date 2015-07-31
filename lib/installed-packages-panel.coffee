{$$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class InstalledPackagesPanel extends View
  @content: ->
    @div =>
      @text "this is installed packages panel"
