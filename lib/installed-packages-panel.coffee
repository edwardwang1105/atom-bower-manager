{$$, TextEditorView, View} = require 'atom-space-pen-views'

class InstalledPackagesPanel extends View
  @content: ->
    @div =>
      @text "this is installed packages panel"
