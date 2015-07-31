{$, $$, TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
class InstallPanel extends View
  @content: ->
    @div =>
      @text "This is install panel."
